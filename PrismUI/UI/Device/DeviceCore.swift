//
//  DeviceCore.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/17/22.
//

import Foundation
import ComposableArchitecture
import PrismKit

struct DeviceState: Equatable {
}

enum DeviceAction: Equatable {
}

struct DeviceEnvironment {
    
}

let deviceReducer = Reducer<SSDevice, DeviceAction, DeviceEnvironment> { device, action, environment in
        .none
}
