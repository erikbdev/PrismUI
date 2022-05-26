//
//  PrismDevice+Ext.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/16/21.
//

import Foundation
import PrismClient

extension PrismDevice.State {
    var image: String {
        switch model {
        case .perKey, .perKeyShort:
            return "PerKeyKeyboard"
        default:
            return ""
        }
    }
}
