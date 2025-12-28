import Foundation

struct HistoryPoint: Codable, Identifiable {
    var id: Date { date }
    let date: Date
    let level: Int
}

final class HistoryManager: @unchecked Sendable {
    static let shared = HistoryManager()
    
    private var history: [String: [HistoryPoint]] = [:]
    private let fileURL: URL
    private let queue = DispatchQueue(label: "com.voltara.history", qos: .utility)
    
    init() {
        // Setup file path in Application Support
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let voltaraDir = appSupport.appendingPathComponent("Voltara")
        
        // Ensure dir exists
        try? FileManager.default.createDirectory(at: voltaraDir, withIntermediateDirectories: true)
        
        self.fileURL = voltaraDir.appendingPathComponent("battery_history.json")
        self.load()
    }
    
    func addPoint(deviceId: String, level: Int) {
        queue.async {
            var points = self.history[deviceId] ?? []
            
            // Prune old data (> 24 hours)
            let twentyFourHoursAgo = Date().addingTimeInterval(-86400)
            if let first = points.first, first.date < twentyFourHoursAgo {
                 points = points.filter { $0.date > twentyFourHoursAgo }
            }
            
            // Add new point logic using "Latest"
            // We want to capture changes, but minimize storage
            // Strategy: Add point if > 10 minutes since last OR if level changed
            
            var shouldAdd = false
            if let last = points.last {
                let timeDiff = abs(last.date.timeIntervalSinceNow)
                if last.level != level {
                    shouldAdd = true // Level changed
                } else if timeDiff > 600 { // 10 minutes
                    shouldAdd = true
                }
            } else {
                shouldAdd = true // First point
            }
            
            if shouldAdd {
                points.append(HistoryPoint(date: Date(), level: level))
                self.history[deviceId] = points
                self.save()
            }
        }
    }
    
    func getHistory(for deviceId: String) -> [HistoryPoint] {
        return queue.sync {
            return history[deviceId] ?? []
        }
    }
    
    private func save() {
        // Must be called on queue
        if let data = try? JSONEncoder().encode(self.history) {
            try? data.write(to: self.fileURL)
        }
    }
    
    private func load() {
        // Called in init
        if let data = try? Data(contentsOf: fileURL),
           let loaded = try? JSONDecoder().decode([String: [HistoryPoint]].self, from: data) {
            self.history = loaded
        }
    }
}
