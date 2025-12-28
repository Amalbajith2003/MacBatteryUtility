
import Foundation
import IOKit

/// Represents a snapshot of battery state
struct BatteryStats: CustomStringConvertible {
    let currentCapacity: Int    // mAh
    let maxCapacity: Int        // mAh
    let designCapacity: Int     // mAh (defaulting to max if 0)
    let cycleCount: Int
    let voltage: Int            // mV
    let amperage: Int           // mA (negative = discharging)
    let isCharging: Bool
    let temperature: Double     // Celsius
    let timeRemaining: Int      // Minutes (-1 if unknown)
    
    var health: Double {
        guard designCapacity > 0 else { return 100.0 }
        return (Double(maxCapacity) / Double(designCapacity)) * 100.0
    }
    
    var watts: Double {
        // W = (mV * mA) / 1,000,000
        return (Double(voltage) * Double(amperage)) / 1_000_000.0
    }
    
    var description: String {
        return """
        Health: \(String(format: "%.1f", health))% (Cycles: \(cycleCount))
        Charge: \(currentCapacity)/\(maxCapacity) mAh
        Power:  \(String(format: "%.2f", watts)) W (\(voltage) mV, \(amperage) mA)
        Temp:   \(temperature)°C
        State:  \(isCharging ? "Charging" : "Discharging")
        """
    }
}

class BatteryService {
    
    func getStats() -> BatteryStats? {
        // 1. Prepare matching dictionary for AppleSmartBattery
        let serviceName = "AppleSmartBattery"
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceNameMatching(serviceName))
        
        guard service != 0 else {
            print("Error: Could not find \(serviceName) service.")
            return nil
        }
        defer { IOObjectRelease(service) }
        
        // 2. Fetch Properties
        // We use a helper to get Int/Bool values easily
        guard let props = getProperties(for: service) else { return nil }
        
        // Prefer "AppleRaw..." keys for unscaled mAh values on Apple Silicon / recent macOS
        let currentCap = (props["AppleRawCurrentCapacity"] as? Int) ?? (props["CurrentCapacity"] as? Int) ?? 0
        let maxCap = (props["AppleRawMaxCapacity"] as? Int) ?? (props["MaxCapacity"] as? Int) ?? 0
        let designCap = props["DesignCapacity"] as? Int ?? 0
        let cycleCount = props["CycleCount"] as? Int ?? 0
        let voltage = props["Voltage"] as? Int ?? 0
        let amperage = props["Amperage"] as? Int ?? 0
        let isCharging = (props["IsCharging"] as? Bool) ?? false
        let tempRaw = props["Temperature"] as? Int ?? 0
        let temperature = Double(tempRaw) / 100.0
        
        // Time Remaining Logic
        // 65535 often means "calculating" or "unknown"
        var timeRemaining = (props["TimeRemaining"] as? Int) ?? -1
        
        if timeRemaining == 65535 || timeRemaining == -1 {
            if isCharging {
                timeRemaining = (props["AvgTimeToFull"] as? Int) ?? (props["InstantTimeToFull"] as? Int) ?? -1
            } else {
                timeRemaining = (props["AvgTimeToEmpty"] as? Int) ?? (props["InstantTimeToEmpty"] as? Int) ?? -1
            }
        }
        
        if timeRemaining == 65535 { timeRemaining = -1 }
        
        return BatteryStats(
            currentCapacity: currentCap,
            maxCapacity: maxCap,
            designCapacity: designCap == 0 ? maxCap : designCap,
            cycleCount: cycleCount,
            voltage: voltage,
            amperage: amperage,
            isCharging: isCharging,
            temperature: temperature,
            timeRemaining: timeRemaining
        )
    }
    
    private func getProperties(for service: io_service_t) -> [String: Any]? {
        var props: Unmanaged<CFMutableDictionary>? = nil
        let result = IORegistryEntryCreateCFProperties(service, &props, kCFAllocatorDefault, 0)
        
        guard result == kIOReturnSuccess, let properties = props?.takeRetainedValue() as? [String: Any] else {
            return nil
        }
        return properties
    }
}
