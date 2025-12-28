import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BatteryViewModel()
    
    var body: some View {
        ZStack {
            // Background
            Theme.background(for: .light) // Force light/dark based on system later, using default env for now
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("My Devices")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                    Button(action: {
                        // Open Settings
                    }) {
                        Image(systemName: "gearshape")
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
                .background(Theme.background(for: .light)) // Sticky header effect
                
                // Device List
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.displayDevices) { device in
                            DeviceCard(
                                name: device.name,
                                iconName: device.icon,
                                statusText: device.statusText,
                                batteryLevel: device.level,
                                isCharging: device.isCharging,
                                statusColor: device.color,
                                subStatusText: device.subStatusText,
                                isPrimary: device.isPrimary
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100) // Space for FAB
                }
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                Button(action: {
                    // Add Device Action
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                        Text("Add Device")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(Theme.primary)
                    .cornerRadius(28)
                    .shadow(color: Theme.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 24)
            }
        }
        .frame(minWidth: 400, minHeight: 600)
    }
}
