//
//  Live.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/18/22.
//

import Combine
import ComposableArchitecture
import IOKit.hid

public extension DeviceScanner {
    static let live: Self = {
        var manager = Self()

        manager.create = { id, loop, loopMode in
            Effect.run { subscriber in
                let delegate = DeviceScannerDelegate(subscriber)
                let manager = IOHIDManagerCreate(with: delegate)

                IOHIDManagerScheduleWithRunLoop(manager, loop, loopMode.rawValue)

                dependencies[id] = Dependencies(
                    delegate: delegate,
                    manager: manager,
                    subscriber: subscriber
                )

                return AnyCancellable {
                    dependencies[id]?.manager.close()
                    dependencies[id] = nil
                }
            }
        }

        manager.destroy = { id in
            .fireAndForget {
                dependencies[id]?.subscriber.send(completion: .finished)
                dependencies[id]?.manager.close()
                dependencies[id] = nil
            }
        }

        manager.scan = { id in
            .fireAndForget {
                dependencies[id]?.manager.setDeviceMatchingMultiple(products: Models.allCases.map({ $0.productInformation() }))
                dependencies[id]?.manager.open()
            }
        }

//        manager.retrieveDevices = { id in
//            if let devices = dependencies[id]?.manager.copyDevices() as? Set<IOHIDDevice> {
//                return devices.compactMap { try? Device(hidDevice: $0) }
//            }
//            return nil
//        }

        return manager
    }()
}

private struct Dependencies {
    let delegate: DeviceScannerDelegate
    let manager: IOHIDManager
    let subscriber: Effect<DeviceScanner.Event, Never>.Subscriber
}

private var dependencies: [AnyHashable: Dependencies] = [:]

private class DeviceScannerDelegate: NSObject {
    let subscriber: Effect<DeviceScanner.Event, Never>.Subscriber

    init(_ subscriber: Effect<DeviceScanner.Event, Never>.Subscriber) {
        self.subscriber = subscriber
    }

    var matchingCallback: IOHIDDeviceCallback = { context, _, _, hidDevice in
        let this = unsafeBitCast(context, to: DeviceScannerDelegate.self)
        if let device = try? Device(hidDevice: hidDevice) {
            this.subscriber.send(.didDiscover(device, error: nil))
        }
    }

    var removalCallback: IOHIDDeviceCallback = { context, _, _, hidDevice in
        let this = unsafeBitCast(context, to: DeviceScannerDelegate.self)
        if let device = try? Device(hidDevice: hidDevice) {
            this.subscriber.send(.didRemove(device, error: nil))
        }
    }
}

private func IOHIDManagerCreate(with delegate: DeviceScannerDelegate) -> IOHIDManager {
    let manager = IOKit.IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))

    let context = unsafeBitCast(delegate, to: UnsafeMutableRawPointer.self)
    manager.registerDeviceMatchingCallback(delegate.matchingCallback, context: context)
    manager.registerDeviceRemovalCallback(delegate.removalCallback, context: context)
    return manager
}
