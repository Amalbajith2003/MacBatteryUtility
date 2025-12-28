import SwiftUI

struct DeviceDetailsView: View {
    let device: BatteryViewModel.DeviceDisplayModel
    let stats: BatteryStats? // Needed for Mac specific detailed stats
    let iosDevice: IOSDevice? // Needed for iOS specific detailed stats
    let onDismiss: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Theme.background(for: .light)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                            .frame(width: 40, height: 40)
                            .background(Color.primary.opacity(0.05))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    Text("Device Details")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                            .frame(width: 40, height: 40)
                            .background(Color.primary.opacity(0.05))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(Theme.background(for: .light))
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Hero Status
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .stroke(Color.primary.opacity(0.05), lineWidth: 8)
                                    .frame(width: 160, height: 160)
                                    
                                Circle()
                                    .trim(from: 0, to: CGFloat(device.level) / 100.0)
                                    .stroke(device.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 160, height: 160)
                                
                                VStack(spacing: 4) {
                                    Image(systemName: device.icon)
                                        .font(.system(size: 32))
                                        .foregroundColor(device.color)
                                    Text("\(device.level)%")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.primary)
                                    Text(device.statusText)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.top, 16)
                            
                            VStack(spacing: 4) {
                                Text(device.name)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white) // In the design this was a dark pill
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.black) // Dark pill
                                    .cornerRadius(12)
                                
                                Text(device.subStatusText)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: 200)
                            }
                        }
                        
                        // Health & Cycle Grid
                        HStack(spacing: 16) {
                            // Health Card
                            DetailedStatCard(
                                icon: "heart.fill",
                                iconColor: Theme.success,
                                iconBg: Theme.success.opacity(0.1),
                                title: "Battery Health",
                                value: getHealthText(),
                                subValue: getHealthStatus()
                            )
                            
                            // Cycle Card
                            DetailedStatCard(
                                icon: "arrow.triangle.2.circlepath",
                                iconColor: Theme.primary,
                                iconBg: Theme.primary.opacity(0.1),
                                title: "Cycle Count",
                                value: getCycleCountText(),
                                subValue: "Cycles"
                            )
                        }
                        .padding(.horizontal, 16)
                        
                        // Technical Specs List
                        VStack(spacing: 0) {
                            HStack {
                                Text("Technical Specs")
                                    .font(.system(size: 16, weight: .bold))
                                Spacer()
                                Image(systemName: "info.circle")
                                    .foregroundColor(.secondary)
                            }
                            .padding(20)
                            .background(Color.white.opacity(0.5)) // Slightly distinct header
                            
                            Divider()
                            
                            TechSpecRow(
                                icon: "battery.100",
                                label: "Design Capacity",
                                subLabel: "Factory standard",
                                value: getDesignCapacity()
                            )
                            
                            Divider().padding(.leading, 64)
                            
                            TechSpecRow(
                                icon: "bolt.fill",
                                label: "Full Charge Cap.",
                                subLabel: "Current max",
                                value: getMaxCapacity()
                            )
                            
                            Divider().padding(.leading, 64)
                            
                            if let mac = stats {
                                TechSpecRow(
                                    icon: "thermometer",
                                    label: "Temperature",
                                    subLabel: "Current status",
                                    value: String(format: "%.1f°C", mac.temperature)
                                )
                                Divider().padding(.leading, 64)
                                TechSpecRow(
                                    icon: "power",
                                    label: "Voltage",
                                    subLabel: "Instantaneous",
                                    value: String(format: "%.2f V", mac.voltage / 1000.0)
                                )
                            }
                        }
                        .background(Theme.surface(for: .light))
                        .cornerRadius(24)
                        .padding(.horizontal, 16)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        // Fake Graph (Placeholder)
                        VStack(alignment: .leading) {
                            Text("Last 24 Hours")
                                .font(.system(size: 16, weight: .bold))
                                .padding(.bottom, 16)
                            
                            HStack(alignment: .bottom, spacing: 6) {
                                ForEach(0..<8) { i in
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Theme.primary.opacity(0.2))
                                        .frame(height: CGFloat([40, 35, 30, 50, 80, 75, 60, 45][i]))
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .frame(height: 100)
                            
                            HStack {
                                Text("12 AM").font(.caption).foregroundColor(.secondary)
                                Spacer()
                                Text("12 PM").font(.caption).foregroundColor(.secondary)
                                Spacer()
                                Text("Now").font(.caption).foregroundColor(.secondary)
                            }
                            .padding(.top, 8)
                        }
                        .padding(20)
                        .background(Theme.surface(for: .light))
                        .cornerRadius(24)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }
    
    // Helpers
    func getHealthText() -> String {
        if let mac = stats { return String(format: "%.1f%%", mac.health) }
        if let ios = iosDevice { 
            return ios.maxCapacity > 0 ? String(format: "%.1f%%", ios.health) : "Locked"
        }
        return "--"
    }
    
    func getHealthStatus() -> String {
        if let mac = stats { return mac.health >= 80 ? "Excellent" : "Service" }
        if let ios = iosDevice { return ios.health >= 80 ? "Excellent" : "Service" }
        return "--"
    }
    
    func getCycleCountText() -> String {
        if let mac = stats { return "\(mac.cycleCount)" }
        if let ios = iosDevice { return ios.cycleCount > 0 ? "\(ios.cycleCount)" : "Locked" }
        return "--"
    }
    
    func getDesignCapacity() -> String {
        if let mac = stats { return "\(mac.designCapacity) mAh" }
        if let ios = iosDevice { return ios.designCapacity > 0 ? "\(ios.designCapacity) mAh" : "Unknown" }
        return "--"
    }
    
    func getMaxCapacity() -> String {
        if let mac = stats { return "\(mac.maxCapacity) mAh" }
        if let ios = iosDevice { return ios.maxCapacity > 0 ? "\(ios.maxCapacity) mAh" : "Restricted" }
        return "--"
    }
}

struct DetailedStatCard: View {
    let icon: String
    let iconColor: Color
    let iconBg: Color
    let title: String
    let value: String
    let subValue: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                 Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 36, height: 36)
                    .background(iconBg)
                    .cornerRadius(8)
                 Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                Text(subValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(iconColor)
            }
        }
        .padding(16)
        .background(Theme.surface(for: .light))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
        .frame(maxWidth: .infinity)
    }
}

struct TechSpecRow: View {
    let icon: String
    let label: String
    let subLabel: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.secondary)
                .frame(width: 36, height: 36)
                .background(Color.primary.opacity(0.05))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                Text(subLabel)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
        }
        .padding(16)
    }
}
