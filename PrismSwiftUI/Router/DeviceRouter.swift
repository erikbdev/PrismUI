//
//  DeviceRouter.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/17/21.
//

import Foundation
import PrismKit
import SwiftUI

class DeviceRouter {
    static func route(device: PrismDevice) -> AnyView {
        if device.ssDevice.model == .perKeyGS65 || device.ssDevice.model == .perKey {
            return AnyView(PerKeyKeyboardView(device: device))
        }
        
        return AnyView(Text("Model not found"))
    }
}
