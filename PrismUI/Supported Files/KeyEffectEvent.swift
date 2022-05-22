//
//  KeyEffectEvent.swift
//  PrismUI
//
//  Created by Erik Bautista on 2/10/22.
//

import Foundation
import PrismClient

enum KeyEffectEvent {
    case steady(color: HSB)
    case colorShift(colorSelectors: [ColorSelector], speed: CGFloat, waveActive: Bool, waveDirection: KeyEffect.Direction, waveControl: KeyEffect.Control, pulse: CGFloat, origin: KeyEffect.PerKeyPoint)
    case breathing(colorSelectors: [ColorSelector], speed: CGFloat)
    case reactive(activeColor: HSB, restColor: HSB, speed: CGFloat)
    case disabled
}
