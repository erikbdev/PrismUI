//
//  KeyEffects.swift
//  PrismUI
//
//  Created by Erik Bautista on 2/10/22.
//

import Foundation
import PrismKit

enum KeyEffects {
    case steady(color: HSB)
    case colorShift(colorSelectors: [ColorSelector], speed: CGFloat, waveActive: Bool, waveDirection: SSKeyEffect.SSPerKeyDirection, waveControl: SSKeyEffect.SSPerKeyControl, pulse: CGFloat, origin: SSKeyEffect.SSPoint)
    case breathing(colorSelectors: [ColorSelector], speed: CGFloat)
    case reactive(activeColor: HSB, restColor: HSB, speed: CGFloat)
    case disabled
}
