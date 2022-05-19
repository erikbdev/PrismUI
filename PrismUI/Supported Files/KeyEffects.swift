//
//  KeyEffects.swift
//  PrismUI
//
//  Created by Erik Bautista on 2/10/22.
//

import Foundation
import PrismClient

enum KeyEffects {
    case steady(color: HSB)
    case colorShift(colorSelectors: [ColorSelector], speed: CGFloat, waveActive: Bool, waveDirection: KeyEffect.SSPerKeyDirection, waveControl: KeyEffect.SSPerKeyControl, pulse: CGFloat, origin: KeyEffect.SSPoint)
    case breathing(colorSelectors: [ColorSelector], speed: CGFloat)
    case reactive(activeColor: HSB, restColor: HSB, speed: CGFloat)
    case disabled
}
