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
    static func route(device: Device) -> some View {
        switch device.model {
            case .perKey, .perKeyGS65:
                PerKeyDeviceViewComp(
                    store: .init(
                        initialState: .init(),
                        reducer: PerKeyDevice.reducer,
                        environment: .init(
                            device: device
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
