import Foundation
import Combine

struct IOSDevice: Identifiable {
    let id: String
    let name: String
    let serialNumber: String
    let productType: String
    let cycleCount: Int
    let designCapacity: Int
    let currentCapacity: Int
    let maxCapacity: Int
    let batteryLevel: Int
    let isCharging: Bool
    let debugInfo: String
    
    var health: Double {
        guard designCapacity > 0 else { return 0 }
        return Double(maxCapacity) / Double(designCapacity) * 100.0
    }
}

class MobileDeviceMonitor: ObservableObject, @unchecked Sendable {
    @Published var connectedDevices: [IOSDevice] = []
    
    private var handle: UnsafeMutableRawPointer? // dlopen handle
    
    // Function pointers
    private var subscribe: AMDeviceNotificationSubscribeFunc?
    private var connect: AMDeviceConnectFunc?
    private var validatePairing: AMDeviceValidatePairingFunc?
    private var startSession: AMDeviceStartSessionFunc?
    private var stopSession: AMDeviceStopSessionFunc?
    private var disconnect: AMDeviceDisconnectFunc?
    private var copyValue: AMDeviceCopyValueFunc?
    private var copyDeviceIdentifier: AMDeviceCopyDeviceIdentifierFunc?
    
    // Keep reference to subscription to prevent dealloc issues if standard API usage (though here it's a raw ptr)
    private var notificationRef: UnsafeMutableRawPointer?
    
    init() {
        loadFramework()
        startMonitoring()
    }
    
    deinit {
        // Technically we should dlclose, but for a singleton app service it's fine.
    }
    
    private func loadFramework() {
        let path = "/System/Library/PrivateFrameworks/MobileDevice.framework/MobileDevice"
        guard let handle = dlopen(path, RTLD_LAZY) else {
            print("Failed to load MobileDevice.framework")
            return
        }
        self.handle = handle
        
        // Helper to load symbol
        func load<T>(_ name: String) -> T? {
            guard let sym = dlsym(handle, name) else { return nil }
            return unsafeBitCast(sym, to: T.self)
        }
        
        self.subscribe = load("AMDeviceNotificationSubscribe")
        self.connect = load("AMDeviceConnect")
        self.validatePairing = load("AMDeviceValidatePairing")
        self.startSession = load("AMDeviceStartSession")
        self.stopSession = load("AMDeviceStopSession")
        self.disconnect = load("AMDeviceDisconnect")
        self.copyValue = load("AMDeviceCopyValue")
        self.copyDeviceIdentifier = load("AMDeviceCopyDeviceIdentifier")
    }
    
    private func startMonitoring() {
        guard let subscribe = self.subscribe else { return }
        
        var ref: UnsafeMutableRawPointer?
        
        let callback: AMDeviceNotificationCallback = { notificationRaw, cookie in
            guard let cookie = cookie else { return }
            let monitor = Unmanaged<MobileDeviceMonitor>.fromOpaque(cookie).takeUnretainedValue()
            
            // Rebind raw pointer to concrete struct pointer
            let notificationPtr = notificationRaw.assumingMemoryBound(to: AMDeviceNotification.self)
            let notification = notificationPtr.pointee
            
            // 1 = Connected, 2 = Disconnected
            if notification.msg == 1 {
                monitor.handleDeviceNotification(device: notification.device)
            } else if notification.msg == 2 {
                monitor.handleDeviceDisconnection(device: notification.device)
            }
        }
        
        // Pass self as cookie
        let unmanaged = Unmanaged.passUnretained(self)
        let cookie = unmanaged.toOpaque()
        
        _ = subscribe(callback, 0, 0, cookie, &ref)
        self.notificationRef = ref
    }
    
    // This runs on a background C thread usually
    nonisolated private func handleDeviceNotification(device: UnsafeMutableRawPointer) {
        // Handle Connection (Msg = 1)
        if let metrics = readDevice(device) {
            Task { @MainActor in
                 self.connectedDevices.removeAll { $0.id == metrics.id }
                 self.connectedDevices.append(metrics)
            }
        }
    }

    nonisolated private func handleDeviceDisconnection(device: UnsafeMutableRawPointer) {
        // Handle Disconnection (Msg = 2)
        // We cannot reliably read from the device if it's gone.
        // Ideally we would map pointer -> ID. 
        // For now, if we can't get ID, we can't remove it specificially. 
        // A better approach would be to store `AMDeviceRef` in IOSDevice, but it's a pointer that might be reused?
        // Let's try to read ID quickly. If it fails, we assume we can't remove it yet (limitation of MVP).
        // OR: Trigger a full refresh of all devices? No generic "list all" API exposed here easily.
        
        // Safe Attempt: Just Copy Identifier. NO Connect/StartSession.
        if let copyId = self.copyDeviceIdentifier,
           let uuidCF = copyId(device) {
            let uuid = uuidCF.takeRetainedValue() as String
            Task { @MainActor in
                self.connectedDevices.removeAll { $0.id == uuid }
            }
        }
    }
    
    nonisolated private func readDevice(_ device: UnsafeMutableRawPointer) -> IOSDevice? {
        // 1. Connect
        guard let connect = self.connect, connect(device) == 0 else { return nil }
        // Always disconnect at end of scope
        defer { _ = self.disconnect?(device) }
        
        // 2. Validate Pairing (Trust)
        guard let validate = self.validatePairing, validate(device) == 0 else {
            print("Device pairing invalid")
            return nil
        }
        
        // 3. Start Session
        guard let startSession = self.startSession, startSession(device) == 0 else { return nil }
        defer { _ = self.stopSession?(device) }
        
        // 4. Data Extraction Helpers
        guard let copyValue = self.copyValue,
              let copyId = self.copyDeviceIdentifier else { return nil }
        
        func getValue(_ key: String, domain: String? = nil) -> Any? {
            let val = copyValue(device, domain as CFString?, key as CFString)
            return val?.takeRetainedValue()
        }
        
        let uuid = (copyId(device)?.takeRetainedValue() as String?) ?? UUID().uuidString
        let name = (getValue("DeviceName") as? String) ?? "Unknown iPhone"
        let serial = (getValue("SerialNumber") as? String) ?? "Unknown"
        let productType = (getValue("ProductType") as? String) ?? "Unknown"
        var debugLog = "Type: \(productType)\n"
        
        // Initialize vars
        var cycleCount = 0
        var designCap = 0
        var maxCap = 0
        var currentCap = 0
        var isCharging = false
        var batteryLevel = 0
        
        // Debug: Dump Domain
        let batteryDomainName = "com.apple.mobile.battery"
        if let domainDict = copyValue(device, batteryDomainName as CFString, nil as CFString?)?.takeRetainedValue() as? [String: Any] {
            debugLog += "DomainKeys: \(domainDict.keys.joined(separator: ","))\n"
            
            // Extract directly from domain dict to be sure
            cycleCount = (domainDict["CycleCount"] as? Int) ?? 0
            
            // Debug GasGauge Type
            if let ggVal = domainDict["GasGaugeCapability"] {
                debugLog += "GGType: \(type(of: ggVal))\n"
                if let gg = ggVal as? [String: Any] {
                     maxCap = (gg["AppleRawMaxCapacity"] as? Int) ?? (gg["AppleMaxCapacity"] as? Int) ?? 0
                     currentCap = (gg["AppleRawCurrentCapacity"] as? Int) ?? (gg["AppleCurrentCapacity"] as? Int) ?? 0
                     designCap = (gg["DesignCapacity"] as? Int) ?? 0
                     cycleCount = (gg["CycleCount"] as? Int) ?? cycleCount
                     debugLog += "GG: Dict Found. rawMax: \(maxCap)\n"
                } else {
                     // GG is likely Bool (True). Keys might be at top level but HIDDEN from enumeration?
                     debugLog += "GG: Bool/Other\n"
                }
            }
            
            // Try explicit hidden keys in com.apple.mobile.battery
            if maxCap == 0 {
                 maxCap = (getValue("AppleRawMaxCapacity", domain: batteryDomainName) as? Int) ?? 0
                 if maxCap == 0 {
                     maxCap = (getValue("NominalChargeCapacity", domain: batteryDomainName) as? Int) ?? 0
                 }
                 debugLog += "ExplicitMax: \(maxCap)\n"
            }
            if currentCap == 0 {
                 currentCap = (getValue("AppleRawCurrentCapacity", domain: batteryDomainName) as? Int) ?? 0
                 if currentCap == 0 {
                     currentCap = (getValue("BatteryCurrentCapacity", domain: batteryDomainName) as? Int) ?? 0
                 }
            }
            if designCap == 0 {
                 designCap = (getValue("DesignCapacity", domain: batteryDomainName) as? Int) ?? 0
            }
            if cycleCount == 0 {
                 cycleCount = (getValue("CycleCount", domain: batteryDomainName) as? Int) ?? 0
            }
            
            if maxCap == 0 {
                // Try direct keys in domain (BatteryMaximumCapacity was missing in log, but check anyway)
                maxCap = (domainDict["BatteryMaximumCapacity"] as? Int) ?? 0
                // If maxCap is 0, this 'rawLevel' is likely Percentage (0-100)
                if maxCap == 0 { 
                    batteryLevel = (domainDict["BatteryCurrentCapacity"] as? Int) ?? currentCap 
                }
            }
        } else {
            debugLog += "Domain: Nil\n"
        }
        
        let batteryDomain = batteryDomainName // Alias
        
        // Fallback: Global/Root Keys
        if maxCap == 0 {
            let globalMax = getValue("BatteryMaximumCapacity") as? Int
            debugLog += "GlobalMax: \(globalMax ?? -1)\n"
            maxCap = globalMax ?? 0
        }
        
        if cycleCount == 0 {
             cycleCount = (getValue("CycleCount", domain: batteryDomain) as? Int) ?? (getValue("CycleCount") as? Int) ?? 0
        }
        if currentCap == 0 {
            currentCap = (getValue("BatteryCurrentCapacity", domain: batteryDomain) as? Int) ?? (getValue("BatteryCurrentCapacity") as? Int) ?? 0
        }
        if !isCharging {
             isCharging = (getValue("BatteryIsCharging", domain: batteryDomain) as? Bool) ?? (getValue("BatteryIsCharging") as? Bool) ?? false
        }
        
        debugLog += "Fallback: Cyc: \(cycleCount), Max: \(maxCap)\n"
        
        // Fixups
        if designCap == 0 { 
            designCap = estimateDesignCapacity(productType: productType)
            debugLog += "Est Design: \(designCap)"
        } else {
            debugLog += "Read Design: \(designCap)"
        }
        
        // Calculate Level
        // If we have mAh values
        if maxCap > 100 {
            batteryLevel = Int((Double(currentCap) / Double(maxCap)) * 100)
        } else {
            // These might be just percentage values
            batteryLevel = currentCap
        }
        
        return IOSDevice(
            id: uuid,
            name: name,
            serialNumber: serial,
            productType: productType,
            cycleCount: cycleCount,
            designCapacity: designCap,
            currentCapacity: currentCap,
            maxCapacity: maxCap,
            batteryLevel: batteryLevel,
            isCharging: isCharging,
            debugInfo: debugLog
        )
    }
    private func estimateDesignCapacity(productType: String) -> Int {
        // Approximate Design Capacities (mAh)
        let map: [String: Int] = [
            // iPhone 16 Series
            "iPhone17,1": 3582, // 16 Pro (Approx)
            "iPhone17,2": 4685, // 16 Pro Max (Approx)
            "iPhone17,3": 3561, // 16
            "iPhone17,4": 4674, // 16 Plus
            
            // iPhone 15 Series
            "iPhone16,2": 4441, "iPhone16,1": 3290, // 15 Pro Max / 15 Pro
            "iPhone15,5": 4323, "iPhone15,4": 4323, // 15 Plus / 15
            "iPhone15,3": 4323, "iPhone15,2": 3200, // 14 Pro Max / 14 Pro
            "iPhone14,8": 4325, "iPhone14,7": 3227, // 14 Plus / 14
            "iPhone14,3": 4352, "iPhone14,2": 3095, // 13 Pro Max / 13 Pro
            "iPhone14,5": 3227, "iPhone14,4": 2406, // 13 / 13 Mini
            "iPhone13,4": 3687, "iPhone13,3": 2815, // 12 Pro Max / 12 Pro
            "iPhone13,2": 2815, "iPhone13,1": 2227, // 12 / 12 Mini
            "iPhone12,1": 3110, "iPhone12,3": 3046, "iPhone12,5": 3969, // 11 series
            "iPhone11,2": 2658, "iPhone11,4": 3174, "iPhone11,6": 3174, // XS / Max
            "iPhone11,8": 2942, // XR
            "iPhone10,3": 2716, "iPhone10,6": 2716, // X
        ]
        return map[productType] ?? 0
    }
}
