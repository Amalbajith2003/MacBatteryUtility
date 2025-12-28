
import SwiftUI

struct MenuBarView: View {
    @Environment(\.openWindow) private var openWindow
    @ObservedObject var viewModel: BatteryViewModel
    
    var body: some View {
        // Stats
        if let stats = viewModel.stats {
            Text("\(Int(ceil((Double(stats.currentCapacity) / Double(stats.maxCapacity)) * 100)))%  \(stats.isCharging ? "Charging" : "Discharging")")
            Text(String(format: "%.1f W Power", stats.watts))
            Text(String(format: "%.1f%% Health", stats.health))
        } else {
            Text("Loading...")
        }
        
        Divider()
        
        Button("Open Voltara") {
            NSApp.activate(ignoringOtherApps: true)
            openWindow(id: "MainWindow")
        }
        .keyboardShortcut("o")
        
        Divider()
        
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
