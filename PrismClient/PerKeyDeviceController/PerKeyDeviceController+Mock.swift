//
//  PerKeyDeviceController+Mock.swift
//  PrismClient
//
//  Created by Erik Bautista on 5/26/22.
//

import Foundation

import ComposableArchitecture

public extension PerKeyDeviceController {
    static func mock(device: HIDCommunication) -> Self {
        let manager = PerKeyDeviceController()
        // TODO: Make unit testing available to avoid bricking keyboard
        return manager
    }
}
