
import Foundation

// MARK: - MobileDevice Types

// Opaque types for C pointers
typealias AMDeviceRef = NSObject
typealias AMDeviceNotificationRef = NSObject

// Function pointer define for the callback
typealias AMDeviceNotificationCallback = @convention(c) (
    _ notification: UnsafeMutableRawPointer,
    _ cookie: UnsafeMutableRawPointer?
) -> Void

// Structure for the notification payload
// Structure for the notification payload
struct AMDeviceNotification {
    var device: UnsafeMutableRawPointer // actually AMDeviceRef
    var msg: UInt32                     // 1=Connected, 2=Disconnected, 3=Unsubscribed
    private var pad: UInt32             // Alignment padding
    var subscription: UnsafeMutableRawPointer? // actually AMDeviceNotificationRef
}

// MARK: - Function Signatures (for dlsym)

/*
 We need to define the signatures of the C functions we will load dynamically.
 */

// AMDeviceNotificationSubscribe(callback, 0, 0, context, &notification)
typealias AMDeviceNotificationSubscribeFunc = @convention(c) (
    _ callback: AMDeviceNotificationCallback,
    _ unused0: UInt32,
    _ unused1: UInt32,
    _ cookie: UnsafeMutableRawPointer?,
    _ notification: UnsafeMutablePointer<UnsafeMutableRawPointer?>
) -> Int32

// AMDeviceConnect(device)
typealias AMDeviceConnectFunc = @convention(c) (_ device: UnsafeMutableRawPointer) -> Int32

// AMDeviceValidatePairing(device)
typealias AMDeviceValidatePairingFunc = @convention(c) (_ device: UnsafeMutableRawPointer) -> Int32

// AMDeviceStartSession(device)
typealias AMDeviceStartSessionFunc = @convention(c) (_ device: UnsafeMutableRawPointer) -> Int32

// AMDeviceStopSession(device)
typealias AMDeviceStopSessionFunc = @convention(c) (_ device: UnsafeMutableRawPointer) -> Int32

// AMDeviceDisconnect(device)
typealias AMDeviceDisconnectFunc = @convention(c) (_ device: UnsafeMutableRawPointer) -> Int32

// AMDeviceCopyValue(device, domain, key) -> CFTypeRef
typealias AMDeviceCopyValueFunc = @convention(c) (
    _ device: UnsafeMutableRawPointer,
    _ domain: CFString?,
    _ key: CFString?
) -> Unmanaged<CFTypeRef>?

// AMDeviceCopyDeviceIdentifier(device) -> CFString
typealias AMDeviceCopyDeviceIdentifierFunc = @convention(c) (
    _ device: UnsafeMutableRawPointer
) -> Unmanaged<CFString>?
