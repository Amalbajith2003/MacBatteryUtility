
import SwiftUI

@main
struct VoltaraApp: App {
    // Shared state object for the menu bar to ensure persistence
    @StateObject private var menuBarViewModel = BatteryViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, minHeight: 300)
        }
        .windowResizability(.contentSize)
        
        MenuBarExtra("Battery Utility", systemImage: "bolt.batteryblock.fill") {
             MenuBarView(viewModel: menuBarViewModel)
        }
        .menuBarExtraStyle(.window)
    }
}
