//
//  RGBModel+Utils.swift
//  PrismKit
//
//  Created by Erik Bautista on 12/1/21.
//

import Foundation

extension RGB {
    public var redUInt: UInt8 {
        return UInt8(round(red * 255))
    }

    public var greenUInt: UInt8 {
        return UInt8(round(green * 255))
    }

    public var blueUInt: UInt8 {
        return UInt8(round(blue * 255))
    }

    public var alphaUInt: UInt8 {
        return UInt8(round(alpha * 255))
    }
}

// MARK: Color Function Methods

extension RGB {
    public static func linearGradient(fromColor: RGB, toColor: RGB, percent: CGFloat) -> RGB {
        let red = lerp(fromValue: fromColor.red, toValue: toColor.red, percent: percent)
        let green = lerp(fromValue: fromColor.green, toValue: toColor.green, percent: percent)
        let blue = lerp(fromValue: fromColor.blue, toValue: toColor.blue, percent: percent)
        let alpha = lerp(fromValue: fromColor.alpha, toValue: toColor.alpha, percent: percent)
        return RGB(red: red, green: green, blue: blue, alpha: alpha)
    }

    public static func blend(src: RGB, dest: RGB) -> RGB {
        let red = alphaOverlay(from: src.red, to: dest.red, alpha: src.alpha)
        let green = alphaOverlay(from: src.green, to: dest.green, alpha: src.alpha)
        let blue = alphaOverlay(from: src.blue, to: dest.blue, alpha: src.alpha)
        let alpha = 1 - (1 - src.alpha) * (1 - dest.alpha)
        return RGB(red: red, green: green, blue: blue, alpha: alpha)
    }

    public static func lerp(fromValue: CGFloat, toValue: CGFloat, percent: CGFloat) -> CGFloat {
        return (toValue - fromValue) * percent + fromValue
    }

    public static func alphaOverlay(from src: CGFloat, to dest: CGFloat, alpha: CGFloat) -> CGFloat {
        return (1 - alpha) * dest + alpha * src
    }

    public static func delta(source: RGB, target: RGB, duration: UInt16) -> RGB {
        var duration = duration
        if duration < 0x21 {
            duration = 0x21
        }

        let divisible: CGFloat = CGFloat(duration * 16) / 0xff
        var deltaR = CGFloat(target.red - source.red) / divisible
        var deltaG = CGFloat(target.green - source.green) / divisible
        var deltaB = CGFloat(target.blue - source.blue) / divisible

        // Handle underflow
        if deltaR < 0.0 { deltaR += 1.0 }
        if deltaG < 0.0 { deltaG += 1.0 }
        if deltaB < 0.0 { deltaB += 1.0 }

        return RGB(red: deltaR, green: deltaG, blue: deltaB)
    }

    public static func undoDelta(base: RGB, target: RGB , duration: UInt16) -> RGB {
        var duration = duration
        if duration < 0x21 {
            duration = 0x21
        }

        var valueR = target.red * CGFloat(duration) / 16
        var valueG = target.green * CGFloat(duration) / 16
        var valueB = target.blue * CGFloat(duration) / 16

        if valueR > 1.0 {
            valueR = ((target.red - 1.0) * CGFloat(duration) / 16)
        }

        valueR += base.red

        if valueG > 1.0 {
            valueG = ((target.green - 1.0) * CGFloat(duration) / 16)
        }

        valueG += base.green

        if valueB > 1.0 {
            valueB = ((target.blue - 1.0) * CGFloat(duration) / 16)
        }

        valueB += base.blue

        return RGB(red: valueR, green: valueG, blue: valueB)
    }
}
