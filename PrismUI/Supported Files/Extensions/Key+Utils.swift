//
//  SSKey+Utils.swift
//  PrismUI
//
//  Created by Erik Bautista on 12/20/21.
//

import Foundation
import PrismClient
import Then


extension Key {
//    func sameEffect(as ssKey: Key) -> Bool {
//        return mode == ssKey.mode &&
//        main == ssKey.main &&
//        active == ssKey.active &&
//        duration == ssKey.duration &&
//        effect == ssKey.effect
//    }
}

extension Key: Identifiable {
    public var id: UInt16 {
        return (UInt16(region) << 8) | UInt16(keycode)
    }
}

extension Key: Then {
}
