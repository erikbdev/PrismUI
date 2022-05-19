//
//  Interface.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/19/22.
//

import ComposableArchitecture

public struct DeviceManager {
    public enum Event: Equatable {
    }

    let device: () -> IOHIDDevice

    var update: () -> Effect<Never, Never> = { .none}
}
