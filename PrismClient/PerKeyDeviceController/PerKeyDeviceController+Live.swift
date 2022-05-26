//
//  PerKeyDeviceController+Live.swift
//  PrismClient
//
//  Created by Erik Bautista on 5/25/22.
//

import ComposableArchitecture
import Combine

public extension PerKeyDeviceController {
    static func live(device: HIDCommunication) -> Self {
        var manager = PerKeyDeviceController()

        manager.updateKeyboard = { data in
            .fireAndForget {
                  print("Update keyboard")
            }
        }

        return manager
    }
}
