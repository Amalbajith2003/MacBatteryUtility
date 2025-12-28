# Voltara ⚡️

**Voltara** is a modern, premium battery utility for macOS that provides detailed insights into your **MacBook's battery health** and any connected **iOS/iPadOS devices**. Designed with a sleek, responsive dashboard, it offers a level of transparency and detail that standard system settings hide.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)

---

## ✨ Features (Version 2.0)

### 🖥️ Mac Battery Insights
Go beyond the menu bar percentage. Voltara utilizes mostly public **IOKit APIs** to expose raw battery data:
*   **Real-time Metrics:** Voltage (mV), Amperage (mA), and Temperature (°C).
*   **Charging Speed:** Live wattage display (e.g., "charging at 65.5 W").
*   **Health Analysis:** True Capacity vs. Design Capacity (Health %) and Cycle Count.
*   **Time Estimates:** Accurate "Time to Full" and "Time to Empty" calculations.

### 📱 iOS & iPadOS Device Monitor
Connect your iPhone or iPad via USB to unlock stats similar to *CoconutBattery*:
*   **Unified Dashboard:** View all your devices in a single, card-based interface.
*   **Battery Stats:** Monitor real-time charge levels and status (Charging/Discharging).
*   **Technical Specs:** View Design Capacity and Max Capacity (where available).
*   *> Note: On newer iOS versions/devices, Apple restricts access to Cycle Count and Health APIs over USB. Voltara handles this gracefully, displaying available data and indicating restricted fields as "Locked".*

### 📊 Historical Data
*   **24-Hour Graph:** Visualizes your battery usage history over the last 24 hours.
*   **Persistence:** Automatically saves battery snapshops locally, building a history even across app restarts.

### 🎨 Modern UI & Experience
*   **Responsive Dashboard:** A dynamic grid layout that adapts perfectly to any window size.
*   **Themes:** Full support for **Dark Mode** and Light Mode (Auto or Manual toggle).
*   **Menu Bar App:** Quick access to essential stats and a "Quit" shortcut directly from your menu bar.
*   **Smooth Navigation:** App-like interactions and transitions.

---

## 🚀 Installation

### Option 1: Download App
Grab the latest release from the [Releases Page](https://github.com/Amalbajith2003/MacBatteryUtility/releases).
1.  Download `Voltara_v2.0.zip`.
2.  Unzip and drag `Voltara.app` to your Applications folder.
3.  Right-click and select "Open" (necessary for unsigned open-source apps).

### Option 2: Build from Source
```bash
git clone https://github.com/Amalbajith2003/MacBatteryUtility.git
cd MacBatteryUtility
swift build -c release
./scripts/package_app.sh
```

---

## 🛠 Tech Stack

*   **Language:** Swift 5+
*   **Frameworks:** SwiftUI, Combine
*   **System APIs:**
    *   `IOKit` (System Power Sources)
    *   `MobileDevice.framework` (iOS Device Communication via USB)
*   **Architecture:** MVVM with Clean Architecture principles.

## 📄 License
This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
