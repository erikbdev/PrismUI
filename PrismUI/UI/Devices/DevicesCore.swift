//
//  DevicesCore.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/17/22.
//

import ComposableArchitecture

struct DevicesState: Equatable {
    var devices: IdentifiedArrayOf<DeviceModel> = []
}

enum DevicesAction: Equatable {
    case device(id: DeviceModel.ID, action: DeviceAction)
}

struct DevicesEnvironment {
    
}

let devicesReducer = Reducer<DevicesState, DevicesAction, DevicesEnvironment>.combine(
    deviceReducer.forEach(
        state: \.devices,
        action: /DevicesAction.device(id:action:),
        environment: { _ in
            DeviceEnvironment()
        }
    ),
    .init { state, action, environment in
        enum TimerId {}

        return .none
    }
)
