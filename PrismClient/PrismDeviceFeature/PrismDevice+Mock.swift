//
//  PrismDevice+Mock.swift
//  PrismClient
//
//  Created by Erik Bautista on 5/24/22.
//

import ComposableArchitecture

extension PrismDevice.State {
    public static func mock(
        identifier: Int,
        name: String,
        model: PrismDevice.Model,
        device: HIDCommunication
    ) -> Self {
        .init(
            identifier: identifier,
            name: name,
            model: model,
            device: device
        )
    }
}
