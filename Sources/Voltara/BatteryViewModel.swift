
import Foundation
import Combine

@MainActor
class BatteryViewModel: ObservableObject {
    @Published var stats: BatteryStats?
    @Published var iosDevices: [IOSDevice] = []
    
    private let service = BatteryService()
    private let iosMonitor = MobileDeviceMonitor()
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    var healthColor: String {
        guard let health = stats?.health else { return "gray" }
        if health >= 90 { return "green" }
        if health >= 80 { return "orange" }
        return "red"
    }

    init() {
        refresh()
        startPolling()
        
        // Forward iosMonitor updates
        iosMonitor.$connectedDevices
            .receive(on: RunLoop.main)
            .assign(to: \.iosDevices, on: self)
            .store(in: &cancellables)
    }
    
    func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }
    
    func refresh() {
        // Since BatteryService is synchronous and fast (IOKit memory read), 
        // we can call it directly. Ideally, offload to background if heavy.
        // For IOKit registry reads, it's generally safe on main thread for simple tools, 
        // but let's be good citizens and strictly speaking we should allow it to be quick.
        if let newStats = service.getStats() {
            self.stats = newStats
        }
        
        // Should we trigger iosMonitor scan? 
        // Monitor is event driven (USB insert), but we could add manual refresh if needed.
    }
}
