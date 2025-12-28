
import Foundation
import Combine
import SwiftUI

@MainActor
class BatteryViewModel: ObservableObject {
    @Published var stats: BatteryStats?
    @Published var iosDevices: [IOSDevice] = []
    
    // Unified Display Model
    struct DeviceDisplayModel: Identifiable {
        let id: String
        let name: String
        let icon: String
        let statusText: String
        let subStatusText: String
        let level: Int
        let isCharging: Bool
        let color: Color
        let isPrimary: Bool // Highlights the card (e.g. Mac or focused device)
    }
    
    @Published var displayDevices: [DeviceDisplayModel] = []
    
    private let service = BatteryService()
    private let iosMonitor = MobileDeviceMonitor()
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        refresh()
        startPolling()
        
        // Forward iosMonitor updates
        iosMonitor.$connectedDevices
            .receive(on: RunLoop.main)
            .sink { [weak self] devices in
                self?.iosDevices = devices
                self?.updateDisplayModels()
            }
            .store(in: &cancellables)
    }
    
    func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }
    
    func refresh() {
        if let newStats = service.getStats() {
            self.stats = newStats
        }
        updateDisplayModels()
    }
    
    private func updateDisplayModels() {
        var models: [DeviceDisplayModel] = []
        
        // 1. Add Mac
        if let mac = stats {
            let level = Int(ceil((Double(mac.currentCapacity) / Double(mac.maxCapacity)) * 100))
            let timeText = (mac.timeRemaining > 0 && mac.timeRemaining < 6000)
                ? (mac.isCharging ? "~\(mac.timeRemaining) min to full" : "~\(mac.timeRemaining) min remaining")
                : (mac.isCharging ? "Calculating..." : "Battery Power")
                
            let macModel = DeviceDisplayModel(
                id: "mac_main",
                name: "MacBook", // Could fetch actual model name
                icon: "laptopcomputer",
                statusText: mac.isCharging ? "Charging" : "Discharging",
                subStatusText: timeText,
                level: level,
                isCharging: mac.isCharging,
                color: mac.isCharging ? Theme.primary : (level < 20 ? Theme.warning : Theme.success),
                isPrimary: mac.isCharging
            )
            models.append(macModel)
        }
        
        // 2. Add iOS Devices
        for device in iosDevices {
            let isLocked = device.maxCapacity == 0
            
            // Determine Color
            var barColor: Color = Theme.success
            if device.batteryLevel < 20 { barColor = Theme.warning }
            if isLocked { barColor = .gray } // Gray if we can't confirm details, but level is usually known?
            
            // Determine Status
            var subStatus = "Unplugged"
            if device.isCharging { 
                subStatus = "Charging" 
                barColor = Theme.primary
            } else if isLocked {
                subStatus = "Basic Info Only"
            } else {
                subStatus = "\(device.currentCapacity) / \(device.maxCapacity) mAh"
            }
            
            let model = DeviceDisplayModel(
                id: device.id,
                name: device.name,
                icon: device.productType.contains("iPad") ? "ipad.landscape" : "iphone",
                statusText: device.isCharging ? "Charging" : "Connected",
                subStatusText: subStatus,
                level: device.batteryLevel,
                isCharging: device.isCharging,
                color: barColor,
                isPrimary: false
            )
            models.append(model)
        }
        
        self.displayDevices = models
    }
}
