//
//  PrismManager+Live.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/18/22.
//

import Combine
import ComposableArchitecture
import IOKit.hid

private struct Dependencies {
    let delegate: PrismManager.Delegate
    let manager: IOHIDManager
    let subscriber: Effect<PrismManager.Action, Never>.Subscriber
}

public extension PrismManager {
    static let live: Self = {
        var manager = Self()

        manager.create = { id, loop, loopMode in
            .run { subscriber in
                let delegate = Delegate(subscriber)
                let manager = IOHIDManagerCreate(with: delegate)

                manager.scheduleWithRunLoop(with: loop, runLoopMode: loopMode)

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
                dependencies[id]?.manager.setDeviceMatchingMultiple(
                    products: PrismDevice.Model.allCases.map { $0.productInformation() }
                )
            }
        }

        manager.retreiveDevices = { id in
            guard let dependency = dependencies[id] else {
                return []
            }

            return dependency
                .manager
                .copyDevices()
                .map(PrismDevice.State.live)
        }

//        manager.deviceEnvironment = { id, deviceId in
//            guard let dependency = dependencies[id] else {
//                return nil
//            }
//
//            let rawDevice = dependency.manager.copyDevices().first { device in
//                id == (try? device.getProperty(key: kIOHIDLocationIDKey))
//            }
//
//            guard let rawDevice = rawDevice else {
//                return nil
//            }
//
//            return PrismDevice.Environment.mock(hidCommunication: rawDevice) { data, bool in
//                    .fireAndForget {
//                        print("update device now!!")
//                    }
//            }
//        }

        return manager
    }()
}

private var dependencies: [AnyHashable: Dependencies] = [:]

extension PrismManager {
    internal class Delegate: NSObject {
        let subscriber: Effect<PrismManager.Action, Never>.Subscriber

        init(_ subscriber: Effect<PrismManager.Action, Never>.Subscriber) {
            self.subscriber = subscriber
        }

        var matchingCallback: IOHIDDeviceCallback = { context, _, _, hidDevice in
            let this = unsafeBitCast(context, to: Delegate.self)
            this.subscriber.send(.didDiscover(PrismDevice.State.live(from: hidDevice)))
        }

        var removalCallback: IOHIDDeviceCallback = { context, _, _, hidDevice in
            let this = unsafeBitCast(context, to: Delegate.self)
            this.subscriber.send(.didRemove(PrismDevice.State.live(from: hidDevice)))
        }
    }
}

private func IOHIDManagerCreate(with delegate: PrismManager.Delegate) -> IOHIDManager {
    let manager = IOKit.IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
    let context = unsafeBitCast(delegate, to: UnsafeMutableRawPointer.self)
    manager.registerDeviceMatchingCallback(delegate.matchingCallback, context: context)
    manager.registerDeviceRemovalCallback(delegate.removalCallback, context: context)
    return manager
}
