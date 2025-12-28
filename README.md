# Mac Battery Utility

**Mac Battery Utility** is an open-source macOS system utility designed to give users transparent, real-time insight into their MacBook battery health and charging behavior using only public macOS APIs.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)

## 🎯 Purpose

macOS provides only basic battery information—a vague "Battery Health" label and no real-time power metrics. This app focuses on **clarity, accuracy, and trust**, exposing raw and derived battery metrics in a clean, understandable way without ads, subscriptions, or closed logic.

## ✨ Core Features (Version 1)

### 🔋 Live Battery Metrics
* **Real-time Stats**: Charge percentage, charging/discharging state, power source.
* **Health Analysis**: Explicit Health % (Current Capacity / Design Capacity) and Cycle Count.
* **Clear Labels**: "Excellent", "Normal", "Worn" based on raw data.

### ⚡ Live Charging Speed
* **Wattage**: See exactly how fast your Mac is charging (e.g., "45W").
* **Voltage & Amperage**: Raw electrical metrics for transparency.

### ⏱️ Time Estimation
* Estimated time to full charge.
* Estimated time to empty.

## 🛠 Architecture

* **Language**: Swift 5+
* **UI**: SwiftUI
* **Data Layer**: IOKit / IOPowerSources (Public APIs only)
* **Philosophy**: Read-only, lightweight, and secure.

## 🚀 Getting Started

### Prerequisites
* macOS 13.0 (Ventura) or later
* Xcode 14+ (for building)

### Building
```bash
git clone https://github.com/yourusername/MacBatteryUtility.git
cd MacBatteryUtility
swift build
swift run
```

## 📄 License
This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---
**Note**: This project is currently in active development.
