//
//  PerKeyController+Interface.swift
//  PrismClient
//
//  Created by Erik Bautista on 5/25/22.
//

import ComposableArchitecture

public struct PerKeyControllerClient {
    var updateKeyboard: ([Key]) -> Effect<Never, Never> = { _ in .none }

    public func updateDevice(keys: [Key]) -> Effect<Never, Never> {
        updateKeyboard(keys)
    }
}
