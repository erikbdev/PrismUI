//
//  RGB+toHSB.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/3/21.
//

import Foundation
import PrismClient
import SwiftUI

extension RGB {

    static func toHSV(r: CGFloat, g: CGFloat, b: CGFloat) -> HSB {
        let min = r < g ? (r < b ? r : b) : (g < b ? g : b)
        let max = r > g ? (r > b ? r : b) : (g > b ? g : b)
        
        let v = max
        let delta = max - min
        
        guard delta > 0.00001 else { return HSB(hue: 0, saturation: 0, brightness: max) }
        guard max > 0 else { return HSB(hue: -1, saturation: 0, brightness: v) } // Undefined, achromatic grey
        let s = delta / max

        let hue: (CGFloat, CGFloat) -> CGFloat = { max, delta -> CGFloat in
            if r == max { return (g-b)/delta } // between yellow & magenta
            else if g == max { return 2 + (b-r)/delta } // between cyan & yellow
            else { return 4 + (r-g)/delta } // between magenta & cyan
        }

        let h = hue(max, delta) * 60 // In degrees

        return HSB(hue: (h < 0 ? h + 360 : h) , saturation: s, brightness: v)
    }

    var hsb: HSB {
        get {
            return RGB.toHSV(r: self.red, g: self.green, b: self.blue)
        }
        set {
            let newRGB = HSB.toRGB(h: newValue.hue, s: newValue.saturation, b: newValue.brightness)
            red = newRGB.red
            green = newRGB.green
            blue = newRGB.blue
            alpha = newRGB.alpha
        }
    }

    static func getColorFromTransition(with percentage: CGFloat, transitions: [Key.Effect.Transition]) -> RGB {
        let colorSelectors = transitions.map({ ColorSelector(color: $0.color, position: $0.position) })
        return getColorFromTransition(with: percentage, transitions: colorSelectors)
    }

    static func getColorFromTransition(with percentage: CGFloat, transitions: [ColorSelector]) -> RGB {
        guard transitions.count > 0 else { return RGB() }

        let from = transitions.last(where: { $0.position <= percentage }) ?? transitions.first
        let to = transitions.first(where: { $0.position >= percentage }) ?? transitions.first

        if let beforeSelector = from, let afterSelector = to, beforeSelector != afterSelector {
            var diff = afterSelector.position - beforeSelector.position
            if diff == 0 {
                diff = 1.0
            } else if diff < 0 {
                diff -= floor(diff)
            }
            var relative = afterSelector.position - percentage
            if relative < 0 {
                relative -= floor(relative)
            }
            let newPosition = 1 - (relative / diff)
            return RGB.linearGradient(fromColor: beforeSelector.color,
                                      toColor: afterSelector.color,
                                      percent: newPosition)
        } else if let beforeColor = from {
            return beforeColor.color
        } else if let afterColor = to {
            return afterColor.color
        }

        return RGB()
    }
}
