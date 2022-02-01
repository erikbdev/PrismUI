//
//  HSB+Color.swift
//  PrismUI
//
//  Created by Erik Bautista on 1/31/22.
//

import SwiftUI

extension HSB {
    var color: Color {
        Color(hue: hue / 360.0, saturation: saturation, brightness: brightness, opacity: alpha)
    }
}
