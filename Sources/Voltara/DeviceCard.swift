import SwiftUI

struct DeviceCard: View {
    let name: String
    let iconName: String
    let statusText: String
    let batteryLevel: Int
    let isCharging: Bool
    let statusColor: Color
    let subStatusText: String
    let isPrimary: Bool // Emphasize border like the MacBook example in HTML
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .center) {
                HStack(spacing: 16) {
                    // Icon Box
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colorScheme == .dark ? Color(hex: "232f48") : Color(hex: "f1f5f9"))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: iconName)
                            .font(.system(size: 24))
                            .foregroundColor(colorScheme == .dark ? .white : .gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        HStack(spacing: 4) {
                            Text(statusText)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(isCharging ? Theme.primary : Color.secondary)
                            
                            if isCharging {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(Theme.primary)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Status Icon (Top Right)
                if isCharging {
                    // Nothing or custom icon
                } else {
                   // Example: Cloud off or similar from HTML design
                   // Image(systemName: "icloud.slash")
                   //     .foregroundColor(.secondary)
                }
            }
            
            // Battery Bar Section
            VStack(spacing: 8) {
                HStack {
                    Text("Battery Level")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(batteryLevel)%")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(colorScheme == .dark ? Color(hex: "324467") : Color(hex: "f1f5f9"))
                        
                        Capsule()
                            .fill(statusColor)
                            .frame(width: geo.size.width * (CGFloat(batteryLevel) / 100.0))
                    }
                }
                .frame(height: 8)
                
                Text(subStatusText)
                    .font(.system(size: 12))
                    .foregroundColor(isCharging ? Theme.primary.opacity(0.8) : .secondary)
            }
        }
        .padding(20)
        .background(Theme.surface(for: colorScheme))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isPrimary ? Theme.primary : (colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05)), lineWidth: isPrimary ? 2 : 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
