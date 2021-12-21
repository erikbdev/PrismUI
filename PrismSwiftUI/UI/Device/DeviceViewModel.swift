//
//  DeviceViewModel.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/1/21.
//

import Foundation
import PrismKit
import Combine

class DeviceViewModel: BaseViewModel {
    let ssDevice: SSDevice

    var model: SSModels {
        return ssDevice.model
    }

    init(ssDevice: SSDevice) {
        self.ssDevice = ssDevice
    }
}
