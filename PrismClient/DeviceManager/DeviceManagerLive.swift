//
//  Live.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/19/22.
//

import ComposableArchitecture
import Combine

public extension DeviceManager {
    static let live: Self = {
        var manager = Self()

        manager.create = { id, device in
            .run { subscriber in

                dependencies[id] = device

                return AnyCancellable {
                    dependencies[id] = nil
                }
            }
        }

        manager.update = { id, data in
            .fireAndForget {
                dependencies[id]?.update(data: data, force: false)
            }
        }

        return manager
    }()
}


private struct Dependencies {
    let device: Device

//    let subscriber: Effect<Subscriber, Never>
}

private var dependencies: [AnyHashable: Device] = [:]
