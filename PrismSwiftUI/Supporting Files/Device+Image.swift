//
//  Device+Image.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/16/21.
//

import Foundation
import PrismKit

extension PrismDevice {
    var image: String {
        switch ssDevice.model {
        case .perKey, .perKeyGS65:
            return "PerKeyKeyboard"
        default:
            return ""
        }
    }
}
