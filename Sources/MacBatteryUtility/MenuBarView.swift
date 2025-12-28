
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var viewModel: BatteryViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            if let stats = viewModel.stats {
                HStack {
                    Text("\(Int(ceil((Double(stats.currentCapacity) / Double(stats.maxCapacity)) * 100)))%")
                        .font(.headline)
                    Spacer()
                    Text(stats.isCharging ? "Charging" : "Discharging")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                HStack {
                    Image(systemName: "bolt.fill")
                    Text(String(format: "%.1f W", stats.watts))
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "heart.fill")
                    Text(String(format: "%.1f%% Health", stats.health))
                    Spacer()
                }
                
                Divider()
                
                Button("Open Open Battery Utility") {
                    NSApp.activate(ignoringOtherApps: true)
                    // In a WindowGroup app, the main window is usually already available or can be brought to front.
                    // This is a simple handler.
                    if let window = NSApp.windows.first {
                        window.makeKeyAndOrderFront(nil)
                    }
                }
                .keyboardShortcut("o")
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
            } else {
                Text("Loading...")
            }
        }
        .padding()
    }
}
