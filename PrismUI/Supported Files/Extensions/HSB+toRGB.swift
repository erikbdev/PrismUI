//
//  HSV+Color.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/17/21.
//

import SwiftUI
import PrismKit

extension HSB {
    static func toRGB(h: CGFloat, s: CGFloat, b: CGFloat) -> RGB {
        if s == 0 { return RGB(red: b, green: b, blue: b) } // Achromatic grey

        let angle = (h >= 360 ? 0 : h)
        let sector = angle / 60 // Sector
        let i = floor(sector)
        let f = sector - i // Factorial part of h

        let p = b * (1 - s)
        let q = b * (1 - (s * f))
        let t = b * (1 - (s * (1 - f)))

        switch(i) {
        case 0:
            return RGB(red: b, green: t, blue: p)
        case 1:
            return RGB(red: q, green: b, blue: p)
        case 2:
            return RGB(red: p, green: b, blue: t)
        case 3:
            return RGB(red: p, green: q, blue: b)
        case 4:
            return RGB(red: t, green: p, blue: b)
        default:
            return RGB(red: b, green: p, blue: q)
        }
    }

    var rgb: RGB {
        get {
            return HSB.toRGB(h: hue, s: saturation, b: brightness)
        }
        set {
            let newHSV = RGB.toHSV(r: newValue.red, g: newValue.green, b: newValue.blue)
            hue = newHSV.hue
            saturation = newHSV.saturation
            brightness = newHSV.brightness
        }
    }
}
