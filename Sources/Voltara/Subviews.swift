
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
                // Health
                if device.maxCapacity > 0 {
                    MetricCard(title: "Health", value: String(format: "%.1f%%", device.health), icon: "heart.fill", color: (device.health >= 80 ? .green : .orange))
                } else {
                    MetricCard(title: "Health", value: "Locked", icon: "lock.fill", color: .gray)
                }
                
                // Cycles
                if device.cycleCount > 0 {
                     MetricCard(title: "Cycles", value: "\(device.cycleCount)", icon: "arrow.triangle.2.circlepath", color: .blue)
                } else {
                     MetricCard(title: "Cycles", value: "Locked", icon: "lock.fill", color: .gray)
                }
                
                // Capacity
                if device.maxCapacity > 0 {
                    MetricCard(title: "Capacity", value: "\(device.currentCapacity) mAh", icon: "battery.100", color: .gray)
                } else {
                    // Fallback to displaying just level % if real mAh is hidden
                    MetricCard(title: "Level", value: "\(device.batteryLevel)%", icon: "battery.100", color: .green)
                }
                
                // Design
                if device.designCapacity > 0 {
                    MetricCard(title: "Design", value: "\(device.designCapacity) mAh", icon: "ruler", color: .purple)
                } else {
                    MetricCard(title: "Design", value: "Unknown", icon: "questionmark.circle", color: .secondary)
                }
            }
            
            // Details
            VStack(alignment: .leading, spacing: 8) {
                Text("Device Details")
                    .font(.headline)
                    .padding(.bottom, 4)
                    
                DetailRow(label: "Name", value: device.name)
                DetailRow(label: "Model", value: device.productType)
                
                if device.maxCapacity > 0 {
                    DetailRow(label: "Max Capacity", value: "\(device.maxCapacity) mAh")
                } else {
                    DetailRow(label: "Max Capacity", value: "Restricted by iOS")
                }
                
                if device.designCapacity > 0 {
                    DetailRow(label: "Design Capacity", value: "\(device.designCapacity) mAh")
                }
                
                // Explain restriction if detected
                if device.maxCapacity == 0 {
                   Text("Note: Apple restricts battery health data on newer devices/iOS versions over standard USB connection.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Minimal Debug for other issues
                /*
                if !device.debugInfo.isEmpty {
                   Text("Debug: " + device.debugInfo.replacingOccurrences(of: "\n", with: ", "))
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
                */
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)
            
            Spacer()
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            Text(value)
                .font(.title2)
                .bold()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(.body, design: .monospaced))
        }
    }
}
