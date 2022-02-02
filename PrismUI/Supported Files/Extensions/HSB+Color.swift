//
//  HSB+Color.swift
//  PrismUI
//
//  Created by Erik Bautista on 1/31/22.
//

import SwiftUI

extension HSB {
    var color: Color {
        get {
            Color(hue: hue / 360.0, saturation: saturation, brightness: brightness, opacity: alpha)
        }
        set {
            if let cgColor = newValue.cgColor {
                let color = NSColor(cgColor: cgColor)
                var h: CGFloat = 0.0
                var s: CGFloat = 0.0
                var b: CGFloat = 0.0
                var a: CGFloat = 0.0

                color?.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
                
                hue = h * 360.0
                saturation = s
                brightness = b
                alpha = a
            }
        }
    }
}
