//
//  PerKeyControllerClient+Mock.swift
//  PrismClient
//
//  Created by Erik Bautista on 5/27/22.
//

import Foundation

extension PerKeyControllerClient {
    public static func mock(for device: PrismDevice.State) -> Self {
        var manager = Self()
        return manager
    }
}
