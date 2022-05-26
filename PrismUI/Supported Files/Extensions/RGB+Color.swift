//
//  RGB+Color.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/24/22.
//

import SwiftUI
import PrismClient

extension RGB {
    public var color: Color {
        return Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
