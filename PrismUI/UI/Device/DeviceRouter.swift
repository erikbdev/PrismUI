//
//  DeviceRouter.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/17/21.
//

import PrismKit
import SwiftUI
import ComposableArchitecture

class DeviceRouter {
    @ViewBuilder
    static func route(ssDevice: SSDevice) -> some View {
        switch ssDevice.model {
        case .perKey, .perKeyGS65:
            PerKeyDeviceView(viewModel: .make(extra: .init(device: ssDevice)))
        case .threeRegion:
            Text("Model not supported")
        case .unknown:
            Text("Model not found")
        }
    }

    @ViewBuilder
    static func route(device: DeviceModel) -> some View {
        switch device.model {
        case .perKey, .perKeyGS65:
            Text("Per Key Model")
        case .threeRegion:
            Text("Model not supported")
        case .unknown:
            Text("Model not found")
        }
    }

}
