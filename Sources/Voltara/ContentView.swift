
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BatteryViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            if let stats = viewModel.stats {
                // Header
                HStack {
                    if let imagePath = Bundle.module.path(forResource: "AppIcon", ofType: "jpg"),
                       let nsImage = NSImage(contentsOfFile: imagePath) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 64, height: 64)
                    } else {
                        Image(systemName: stats.isCharging ? "bolt.batteryblock.fill" : "battery.75")
                            .font(.largeTitle)
                            .foregroundColor(stats.isCharging ? .green : .primary)
                    }
                    
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
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(12)
                
            } else {
                ProgressView("Loading Battery Data...")
            }
        }
        .padding()
        .frame(width: 450)
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
