
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BatteryViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // Device Selector (Only if iOS devices connected)
            if !viewModel.iosDevices.isEmpty {
                Picker("Select Device", selection: $selectedDeviceId) {
                    Text("This Mac").tag("mac")
                    ForEach(viewModel.iosDevices) { device in
                        Text(device.name).tag(device.id)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
            }
            
            if selectedDeviceId == "mac" {
                MacBatteryView(stats: viewModel.stats)
            } else if let device = viewModel.iosDevices.first(where: { $0.id == selectedDeviceId }) {
                IOSDeviceView(device: device)
            } else {
                // Fallback if device disconnected while selected
                MacBatteryView(stats: viewModel.stats)
            }
        }
        .padding()
        .frame(width: 450)
        .onAppear {
             // Reset to mac if selection invalid, or keep sticky
        }
        .onChange(of: viewModel.iosDevices.map { $0.id }) { _ in
            // If selected device removed, switch to Mac
            if selectedDeviceId != "mac" && !viewModel.iosDevices.contains(where: { $0.id == selectedDeviceId }) {
                selectedDeviceId = "mac"
            }
        }
    }
    
    @State private var selectedDeviceId: String = "mac"
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
