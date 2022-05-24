//
//  Key.swift
//  PrismKit
//
//  Created by Erik Bautista on 12/21/21.
//

import Foundation

public struct Key {
    public static let empty = Key(name: "", region: 0, keycode: 0)

    // MARK: The region of key

    public let region: UInt8

    // MARK: The Keycode

    public let keycode: UInt8

    // MARK: Name of the key

    public let name: String

    // MARK: Effect

    public var effect: KeyEffect?

//    public var effect: KeyEffect? {
//        didSet {
//            if let start = effect?.transitions.first?.color {
//                main = start
//            }
//        }
//    }
//
    // MARK: The duration of the effect

    public var duration: UInt16 = 0x012c

    // MARK: Main color

    public var main = RGB(red: 1.0, green: 0.0, blue: 0.0)

    // MARK: Active color

    public var active = RGB()

    // MARK: Mode of the key

    public var mode = Modes.steady {
        didSet {
            self.effect = nil
        }
    }

    public init(name: String, region: UInt8, keycode: UInt8) {
        self.name = name
        self.region = region
        self.keycode = keycode
    }

    public enum Modes: Int, Codable, CustomStringConvertible, CaseIterable {
        case steady
        case colorShift
        case breathing
        case reactive
        case disabled
        case mixed

        public var description: String {
            switch self {
            case .steady: return "Steady"
            case .colorShift: return "Color Shift"
            case .breathing: return "Breathing"
            case .reactive: return "Reactive"
            case .disabled: return "Disabled"
            case .mixed: return "Mixed"
            }
        }
    }
}

extension Key: Hashable {}

extension Key: Codable {}

