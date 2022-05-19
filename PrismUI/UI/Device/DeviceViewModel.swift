//
//  DeviceViewModel.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/1/21.
//

import Foundation
import PrismClient
import Combine

class DeviceViewModel: BaseViewModel {
    let ssDevice: Device

    var model: Models {
        return ssDevice.model
    }

    init(ssDevice: Device) {
        self.ssDevice = ssDevice
    }
}
