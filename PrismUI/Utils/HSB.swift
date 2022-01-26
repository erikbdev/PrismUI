//
//  HSB.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/17/21.
//

import PrismKit

public struct HSB: Hashable {
    var hue: CGFloat // Angle in degrees [0,360] or -1 as Undefined
    var saturation: CGFloat // Percent [0,1]
    var brightness: CGFloat // Percent [0,1]
    var alpha: CGFloat = 1.0 // Percent [0,1]

    init() {
        hue = 0
        saturation = 0
        brightness = 0
        alpha = 1.0
    }

    init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat = 1.0) {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.alpha = alpha
    }
}
