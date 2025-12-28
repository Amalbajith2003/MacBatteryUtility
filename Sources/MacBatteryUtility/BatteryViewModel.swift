
import Foundation
import Combine

@MainActor
class BatteryViewModel: ObservableObject {
    @Published var stats: BatteryStats?
    
    private let service = BatteryService()
    private var timer: Timer?
    
    var healthColor: String {
        guard let health = stats?.health else { return "gray" }
        if health >= 90 { return "green" }
        if health >= 80 { return "orange" }
        return "red"
    }

    init() {
        refresh()
        startPolling()
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
    }
}
