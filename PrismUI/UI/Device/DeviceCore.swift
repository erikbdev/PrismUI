//
//  DeviceCore.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/17/22.
//

import Foundation
import ComposableArchitecture
import PrismKit

struct DeviceModel: Equatable, Identifiable {
    let id = UUID()
    var name: String = ""
    var image: String
    var model: SSModels
}

struct DeviceState: Equatable {
}

enum DeviceAction: Equatable {
}

struct DeviceEnvironment {
    
}

let deviceReducer = Reducer<DeviceModel, DeviceAction, DeviceEnvironment> { device, action, environment in
    enum TimerId {}

    return .none
}
