//
//  MathUtils.swift
//  PrismUI
//
//  Created by Erik Bautista on 12/22/21.
//

import Foundation

extension CGFloat {
    func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> CGFloat {
        let result = ((self - from.lowerBound) / (from.upperBound - from.lowerBound)) * (to.upperBound - to.lowerBound) + to.lowerBound
        return result
    }
}
