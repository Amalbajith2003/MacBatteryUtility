
import SwiftUI

struct MenuBarView: View {
    @Environment(\.openWindow) private var openWindow
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
                
                Button("Open Voltara") {
                    NSApp.activate(ignoringOtherApps: true)
                    openWindow(id: "MainWindow")
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
