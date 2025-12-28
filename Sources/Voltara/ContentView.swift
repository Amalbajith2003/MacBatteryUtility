import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BatteryViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    // Settings State
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            // Main Dashboard Layer
            ZStack {
                // Background
                Theme.background(for: isDarkMode ? .dark : .light)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("My Devices")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        Spacer()
                        Button(action: {
                            showSettings.toggle()
                        }) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 18))
                                .foregroundColor(.primary)
                                .frame(width: 40, height: 40)
                                .background(Color.primary.opacity(0.05))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .popover(isPresented: $showSettings, arrowEdge: .bottom) {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Settings")
                                    .font(.headline)
                                
                                Toggle("Dark Mode", isOn: $isDarkMode)
                                    .toggleStyle(.switch)
                                    
                                Divider()
                                
                                Button("Quit Voltara") {
                                    NSApplication.shared.terminate(nil)
                                }
                                .buttonStyle(.plain)
                                .foregroundColor(.red)
                            }
                            .padding()
                            .frame(width: 220)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .background(Theme.background(for: isDarkMode ? .dark : .light))
                    
                    // Device List
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 340), spacing: 16)], spacing: 16) {
                            ForEach(viewModel.displayDevices) { device in
                                Button(action: {
                                    withAnimation(.spring()) {
                                        selectedDevice = device
                                    }
                                }) {
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
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                        .padding(.bottom, 100)
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
            .zIndex(1)
            
            // Detail View Overlay
            if let device = selectedDevice {
                DeviceDetailsView(
                    device: device,
                    stats: device.id == "mac_main" ? viewModel.stats : nil,
                    iosDevice: viewModel.iosDevices.first(where: { $0.id == device.id }),
                    onDismiss: {
                        withAnimation(.spring()) {
                            selectedDevice = nil
                        }
                    }
                )
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .transition(.move(edge: .trailing))
                .zIndex(2)
            }
        }
        .frame(minWidth: 480, minHeight: 640)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    @State private var selectedDevice: BatteryViewModel.DeviceDisplayModel?
}
