//
//  RGB+Color.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/3/21.
//

import Foundation
import PrismKit
import SwiftUI

extension RGB {
    var color: Color {
        get {
            return Color(red: red, green: green, blue: blue)
        }
        set {
            let colorWithDefaultColorSpace = NSColor(newValue)
            guard let nativeColor = colorWithDefaultColorSpace.usingColorSpace(.deviceRGB) else { return }
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0

            nativeColor.getRed(&r, green: &g, blue: &b, alpha: &a)
            red = r
            green = g
            blue = b
            alpha = a
        }
    }

    static func toHSV(r: CGFloat, g: CGFloat, b: CGFloat) -> HSV {
        let min = r < g ? (r < b ? r : b) : (g < b ? g : b)
        let max = r > g ? (r > b ? r : b) : (g > b ? g : b)
        
        let v = max
        let delta = max - min
        
        guard delta > 0.00001 else { return HSV(hue: 0, saturation: 0, brightness: max) }
        guard max > 0 else { return HSV(hue: -1, saturation: 0, brightness: v) } // Undefined, achromatic grey
        let s = delta / max

        let hue: (CGFloat, CGFloat) -> CGFloat = { max, delta -> CGFloat in
            if r == max { return (g-b)/delta } // between yellow & magenta
            else if g == max { return 2 + (b-r)/delta } // between cyan & yellow
            else { return 4 + (r-g)/delta } // between magenta & cyan
        }

        let h = hue(max, delta) * 60 // In degrees

        return HSV(hue: (h < 0 ? h + 360 : h) , saturation: s, brightness: v)
    }

    var hsv: HSV {
        get {
            return RGB.toHSV(r: self.red, g: self.green, b: self.blue)
        }
        set {
            let newRGB = HSV.toRGB(h: newValue.hue, s: newValue.saturation, b: newValue.brightness)
            red = newRGB.red
            green = newRGB.green
            blue = newRGB.blue
            alpha = newRGB.alpha
        }
    }
}
