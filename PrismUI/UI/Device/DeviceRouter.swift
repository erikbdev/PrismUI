//
//  DeviceRouter.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/17/21.
//

import PrismClient
import SwiftUI
import ComposableArchitecture

class DeviceRouter {
    @ViewBuilder
    static func route(device: PrismDevice.State) -> some View {
        switch device.model {
        case .perKey, .perKeyShort:
            PerKeyDeviceView(
                store: .init(
                    initialState: .init(
                        device: device
                    ),
                    reducer: PerKeyDeviceCore.reducer,
                    environment: .init(
                        mainQueue: .main,
                        backgroundQueue: .init(
                            DispatchQueue.global(
                                qos: .background
                            )
                        ),
                        perKeyController: .live(
                            for: device
                        )
                    )
                )
            )
        case .threeRegion:
            Text("Model not supported")
        case .unknown:
            Text("Model not found")
        }
    }
}
