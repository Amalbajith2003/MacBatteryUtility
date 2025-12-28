
import SwiftUI

struct MacBatteryView: View {
    let stats: BatteryStats?
    
    var body: some View {
        VStack(spacing: 20) {
            if let stats = stats {
                // Header
                HStack {
                    Image(systemName: stats.isCharging ? "bolt.batteryblock.fill" : "battery.75")
                        .font(.largeTitle)
                        .foregroundColor(stats.isCharging ? .green : .primary)
                    
                    VStack(alignment: .leading) {
                        Text("\(Int(ceil((Double(stats.currentCapacity) / Double(stats.maxCapacity)) * 100)))%")
                            .font(.system(size: 32, weight: .bold))
                        Text(stats.isCharging ? "Charging" : "Discharging")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(12)
                
                // Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    MetricCard(title: "Health", value: String(format: "%.1f%%", stats.health), icon: "heart.fill", color: .green)
                    MetricCard(title: "Cycles", value: "\(stats.cycleCount)", icon: "arrow.triangle.2.circlepath", color: .blue)
                    MetricCard(title: "Power", value: String(format: "%.1f W", stats.watts), icon: "bolt.fill", color: .yellow)
                    MetricCard(title: "Temp", value: String(format: "%.1f°C", stats.temperature), icon: "thermometer", color: .orange)
                }
                
                // Details
                VStack(alignment: .leading, spacing: 8) {
                    Text("Technical Details")
                        .font(.headline)
                        .padding(.bottom, 4)
                        
                    DetailRow(label: "Design Capacity", value: "\(stats.designCapacity) mAh")
                    DetailRow(label: "Max Capacity", value: "\(stats.maxCapacity) mAh")
                    DetailRow(label: "Voltage / Amperage", value: "\(stats.voltage) mV / \(stats.amperage) mA")
                    
                    if stats.timeRemaining > -1 && stats.timeRemaining < 65535 {
                        let hours = stats.timeRemaining / 60
                        let mins = stats.timeRemaining % 60
                        DetailRow(label: stats.isCharging ? "Time to Full" : "Time to Empty", value: String(format: "%d:%02dh", hours, mins))
                    } else {
                         DetailRow(label: "Time Estimate", value: "Calculating...")
                    }
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(12)
                
            } else {
                ProgressView("Loading Battery Data...")
            }
        }
    }
}

struct IOSDeviceView: View {
    let device: IOSDevice
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "iphone") // Generic, could improve based on model
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text("\(device.batteryLevel)%")
                        .font(.system(size: 32, weight: .bold))
                    Text(device.isCharging ? "Charging" : "Unplugged")
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)
            
            // Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                MetricCard(title: "Health", value: String(format: "%.1f%%", device.health), icon: "heart.fill", color: (device.health >= 80 ? .green : .orange))
                MetricCard(title: "Cycles", value: "\(device.cycleCount)", icon: "arrow.triangle.2.circlepath", color: .blue)
                MetricCard(title: "Capacity", value: "\(device.currentCapacity) mAh", icon: "battery.100", color: .gray)
                // iOS doesn't easily expose watts/temp via standard CopyValue without debug
                MetricCard(title: "Design", value: "\(device.designCapacity) mAh", icon: "ruler", color: .purple)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 8) {
                Text("Device Details")
                    .font(.headline)
                    .padding(.bottom, 4)
                    
                DetailRow(label: "Name", value: device.name)
                // DetailRow(label: "Serial", value: device.serialNumber) // Maybe hide serial for privacy/screens
                DetailRow(label: "Max Capacity", value: "\(device.maxCapacity) mAh")
                DetailRow(label: "Design Capacity", value: "\(device.designCapacity) mAh")
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)
            
            Spacer()
        }
    }
}
