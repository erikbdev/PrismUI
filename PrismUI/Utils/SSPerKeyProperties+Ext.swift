//
//  SSPerKeyProperties+Ext.swift
//  PrismUI
//
//  Created by Erik Bautista on 12/24/21.
//

import Foundation
import PrismKit

// Layout Map
extension SSPerKeyProperties {
    // Not exactly equaling to 20 because of some emtpy spaces in between the keys
    static let perKeyMap: [[CGFloat]] = [
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1.25, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2.75, 1, 1, 1, 1],
        [1.50, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2.50, 1, 1, 1],
        [2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1],
        [2.5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2.5, 1, 1, 1, 1],
        [2, 1, 1, 6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    ]

    // WITHOUT PADDING
    static let perKeyGS65KeyMap: [[CGFloat]] = [
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [0.50, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.50, 1],
        [0.75, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.25, 1],
        [1.25, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.75, 1],
        [1.50, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1.50, 1, 1],
        [1.25, 1, 1, 4.75, 1, 1, 1, 1, 1, 1, 1]
    ]

}
