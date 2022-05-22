//
//  Mocks.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/19/22.
//

import ComposableArchitecture
import Combine

public extension DeviceScanner {
    static let mock: Self = {
        var manager = Self()

        manager.create = { id, loop, loopMode in
            .run { subscriber in
                dependencies[id] = subscriber

                return AnyCancellable {
                    dependencies[id] = nil
                }
            }
        }

        manager.destroy = { id in
            .fireAndForget {
                dependencies[id] = nil
            }
        }

        manager.scan = { id in
            .fireAndForget {
                dependencies[id]?.send(.didDiscover(.init(hidDevice: HIDCommunicationMock.mock, id: 0, name: "Test 0", model: .perKey), error: nil))
                dependencies[id]?.send(.didDiscover(.init(hidDevice: HIDCommunicationMock.mock, id: 1, name: "Test 1", model: .perKeyGS65), error: nil))
                dependencies[id]?.send(.didDiscover(.init(hidDevice: HIDCommunicationMock.mock, id: 2, name: "Test 2", model: .threeRegion), error: nil))
                dependencies[id]?.send(.didDiscover(.init(hidDevice: HIDCommunicationMock.mock, id: 3, name: "Test 3", model: .unknown), error: nil))
            }
        }

        return manager
    }()
}

private var dependencies: [AnyHashable: Effect<DeviceScanner.Event, Never>.Subscriber] = [:]
