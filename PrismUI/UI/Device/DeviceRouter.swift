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
    static func route(_ device: Device) -> some View {
        switch device.model {
        case .perKey, .perKeyGS65:
            PerKeyDeviceView(viewModel: .make(extra: .init(device: device)))
        case .threeRegion:
            Text("Model not supported")
        case .unknown:
            Text("Model not found")
        }
    }

    @ViewBuilder
    static func route(device: Device) -> some View {
        switch device.model {
            case .perKey, .perKeyGS65:
                PerKeyDeviceViewComp(
                    store: .init(
                        initialState: .init(
//                            model: device.model
                        ),
                        reducer: perKeyDeviceReducer,
                        environment: PerKeyDeviceEnvironment(
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

//    @ViewBuilder
//    static func route(store: Store<Device, DeviceAction>) -> some View {
//        PerKeyDeviceViewComp.init(
//            store: .init(
//                initialState: ,
//                reducer: ,
//                environment: )
//        )
//        PerKeyDeviceViewComp(
//            store: store.scope(
//                state: { _ in PerKeyDeviceState() },
//                action: { action in action }
//            )
//        )
//    }
}
