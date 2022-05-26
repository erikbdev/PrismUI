//
//  PrismManager+Mock.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/19/22.
//

import ComposableArchitecture
import Combine

public extension PrismManager {
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
                dependencies[id]?.send(
                    .didDiscover(
                        .init(
                            identifier: 0,
                            name: "Test 0",
                            model: .perKey,
                            device: HIDCommunicationMock.mock
                        )
                    )
                )
                dependencies[id]?.send(
                    .didDiscover(
                        .init(
                            identifier: 1,
                            name: "Test 1",
                            model: .perKeyShort,
                            device: HIDCommunicationMock.mock
                        )
                    )
                )
                dependencies[id]?.send(
                    .didDiscover(
                        .init(
                            identifier: 2,
                            name: "Test 2",
                            model: .threeRegion,
                            device: HIDCommunicationMock.mock
                        )
                    )
                )
                dependencies[id]?.send(
                    .didDiscover(
                        .init(
                            identifier: 3,
                            name: "Test 3",
                            model: .unknown,
                            device: HIDCommunicationMock.mock
                        )
                    )
                )
            }
        }

        return manager
    }()
}

private var dependencies: [AnyHashable: Effect<PrismManager.Action, Never>.Subscriber] = [:]
