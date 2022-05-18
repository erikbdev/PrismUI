//
//  Live.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/18/22.
//

import Combine
import ComposableArchitecture
import PrismKit
import IOKit.hid

extension PrismDeviceManager {
    static let live: Self = {
        var manager = Self()

        manager.create = { id, loop, loopMode in
            Effect.run { subscriber in
                let delegate = PrismDeviceManagerDelegate(subscriber)
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
                dependencies[id]?.manager.setDeviceMatchingMultiple(products: SSModels.allCases.map({ $0.productInformation() }))
                dependencies[id]?.manager.open()
            }
        }

        manager.retrieveDevices = { id in
            if let devices = dependencies[id]?.manager.copyDevices() as? Set<IOHIDDevice> {
                return devices
            }
            return nil
        }

        return manager
    }()
}

private struct Dependencies {
    let delegate: PrismDeviceManagerDelegate
    let manager: IOHIDManager
    let subscriber: Effect<PrismDeviceManager.Action, Never>.Subscriber
}

private var dependencies: [AnyHashable: Dependencies] = [:]

private class PrismDeviceManagerDelegate: NSObject {
    let subscriber: Effect<PrismDeviceManager.Action, Never>.Subscriber

    init(_ subscriber: Effect<PrismDeviceManager.Action, Never>.Subscriber) {
        self.subscriber = subscriber
    }

    var matchingCallback: IOHIDDeviceCallback = { context, _, _, device in
        let this = unsafeBitCast(context, to: PrismDeviceManagerDelegate.self)
        this.subscriber.send(.didDiscover(device, error: nil))
    }

    var removalCallback: IOHIDDeviceCallback = { context, _, _, device in
        let this = unsafeBitCast(context, to: PrismDeviceManagerDelegate.self)
        this.subscriber.send(.didRemove(device, error: nil))
    }
}

private func IOHIDManagerCreate(with delegate: PrismDeviceManagerDelegate) -> IOHIDManager {
    let manager = IOKit.IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))

    let context = unsafeBitCast(delegate, to: UnsafeMutableRawPointer.self)
    manager.registerDeviceMatchingCallback(delegate.matchingCallback, context: context)
    manager.registerDeviceRemovalCallback(delegate.removalCallback, context: context)
    return manager
}
