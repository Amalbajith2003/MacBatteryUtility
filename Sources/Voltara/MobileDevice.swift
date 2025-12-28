
import Foundation

// MARK: - MobileDevice Types

// Opaque types for C pointers
typealias AMDeviceRef = NSObject
typealias AMDeviceNotificationRef = NSObject

// Function pointer define for the callback
typealias AMDeviceNotificationCallback = @convention(c) (
    _ notification: UnsafeMutablePointer<AMDeviceNotification>,
    _ cookie: UnsafeMutableRawPointer?
) -> Void

// Structure for the notification payload
struct AMDeviceNotification {
    var unknown0: UInt32
    var device: UnsafeMutableRawPointer // actually AMDeviceRef
    var unknown1: UInt32 
    var unknown2: UInt32 
    var subscription: UnsafeMutableRawPointer // actually AMDeviceNotificationRef
}

// MARK: - Function Signatures (for dlsym)

/*
 We need to define the signatures of the C functions we will load dynamically.
 */

// AMDeviceNotificationSubscribe(callback, 0, 0, context, &notification)
typealias AMDeviceNotificationSubscribeFunc = @convention(c) (
    _ callback: @escaping AMDeviceNotificationCallback,
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
    _ key: CFString
) -> Unmanaged<CFTypeRef>?

// AMDeviceCopyDeviceIdentifier(device) -> CFString
typealias AMDeviceCopyDeviceIdentifierFunc = @convention(c) (
    _ device: UnsafeMutableRawPointer
) -> Unmanaged<CFString>?
