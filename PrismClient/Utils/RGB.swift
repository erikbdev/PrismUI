//
//  Color.swift
//  PrismKit
//
//  Created by Erik Bautista on 7/21/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation

public struct RGB {
    public var red: CGFloat = 0 {
        didSet { red.clamped(min: 0.0, max: 1.0) }
    }

    public var green: CGFloat = 0 {
        didSet { green.clamped(min: 0.0, max: 1.0) }
    }

    public var blue: CGFloat = 0 {
        didSet { blue.clamped(min: 0.0, max: 1.0) }
    }

    public var alpha: CGFloat = 1 {
        didSet { alpha.clamped(min: 0.0, max: 1.0) }
    }

    public init(red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 1.0) {
        self.red = CGFloat(min(max(red, 0.0), 1.0))
        self.green = CGFloat(min(max(green, 0.0), 1.0))
        self.blue = CGFloat(min(max(blue, 0.0), 1.0))
        self.alpha = CGFloat(min(max(alpha, 0.0), 1.0))
    }

    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 255) {
        let rClamped = CGFloat(min(max(red, 0), 255))
        let gClamped = CGFloat(min(max(green, 0), 255))
        let bClamped = CGFloat(min(max(blue, 0), 255))
        let aClamped = CGFloat(min(max(alpha, 0), 255))
        self.init(
            red: rClamped / 255.0,
            green: gClamped / 255.0,
            blue: bClamped / 255.0,
            alpha: aClamped / 255.0
        )
    }

    public init(red: Int, green: Int, blue: Int, alpha: Int = 255) {
        self.init(
            red: UInt8(red),
            green: UInt8(green),
            blue: UInt8(blue),
            alpha: UInt8(alpha)
        )
    }

    public init(hexString: String) {
        let hexString = hexString
        guard let hexInt = Int(hexString, radix: 16) else {
            self.init(red: 1.0, green: 1.0, blue: 1.0)
            return
        }

        self.init(
            red: CGFloat((hexInt >> 16) & 0xFF) / 255.0,
            green: CGFloat((hexInt >> 8) & 0xFF) / 255.0,
            blue: CGFloat((hexInt >> 0) & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
}

extension RGB: Hashable { }

extension RGB: Codable { }

private extension CGFloat {
    mutating func clamped(min: CGFloat, max: CGFloat) {
        if self > max {
            self = max
        } else if self < min {
            self = min
        }
    }
}
