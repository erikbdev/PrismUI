//
//  SSPerKeyProperties+Layout.swift
//  PrismUI
//
//  Created by Erik Bautista on 12/24/21.
//

import PrismKit

// Layout Map
extension SSPerKeyProperties {
    // Not exactly equaling to 20 because of some emtpy spaces in between the keys

    static let perKeyMap: [[CGFloat]] = [
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],   // 20
        [1.25, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2.75, 1, 1, 1, 1],   // 20
        [1.50, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2.50, 1, 1, 1],      // 19
        [2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1],            // 20
        [2.5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2.5, 1, 1, 1, 1],           // 19
        [2, 1, 1, 6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]                      // 20
    ]

    static let perKeyKeySize: CGFloat = 50.0

    static let perKeyGS65KeyMap: [[CGFloat]] = [
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],          // 15
        [0.50, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.50, 1],    // 15
        [0.75, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.25, 1],    // 15
        [1.25, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.75, 1],       // 15
        [1.50, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.50, 1, 1],       // 15
        [1.25, 1, 1, 4.75, 1, 1, 1, 1, 1, 1, 1]                 // 15
    ]

    static let perKeyGS65KeySize: CGFloat = 60.0

    static func getKeyboardMap(for model: SSModels) -> [[CGFloat]] {
        switch model {
        case .perKey:
            return perKeyMap
        case .perKeyGS65:
            return perKeyGS65KeyMap
        default:
            return []
        }
    }
}
