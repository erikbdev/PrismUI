//
//  Key+Effect.swift
//  PrismClient
//
//  Created by Erik Bautista on 5/23/22.
//

import Foundation

extension Key {
    public struct Effect {

        // MARK: Mode

        public var mode = Key.Effect.Mode.steady {
            didSet {
                // Reset Effect values to default
                transitions = []
                main = RGB()
                active = RGB()
                duration = 0x12c
                waveActive = false
                direction = .xy
                control = .inward
                origin = .init()
                pulse = 100
            }
        }

        // MARK: Transitions

        public var transitions: [Transition] = [] {
            didSet {
                main = transitions.first?.color ?? .init()
            }
        }

        // MARK: Start/Main/Rest color

        public var main = RGB()

        // MARK: Active color for Reactive

        public var active = RGB()

        // MARK: Duration

        public var duration: UInt16 = 0x12c

        // MARK: Wave Settings

        public var waveActive = false {
            didSet {
                if !waveActive {
                    direction = .xy
                    control = .inward
                    origin.x = 0
                    origin.y = 0
                    pulse = 100
                }
            }
        }
        public var direction = Direction.xy
        public var control = Control.inward
        public var origin = Point()
        public var pulse: UInt16 = 100

        public init() {
            mode = .steady
            main = RGB(red: 1.0, green: 0, blue: 0)
        }
    }
}

extension Key.Effect {
    public enum Direction: UInt8, CaseIterable, CustomStringConvertible, Codable {
        case xy = 0
        case x = 1
        case y = 2

        public var description: String {
            switch (self) {
            case .xy:
                return "XY"
            case .x:
                return "X"
            case .y:
                return "Y"
            }
        }
    }

    public enum Control: UInt8, CaseIterable, CustomStringConvertible, Codable {
        case inward = 0
        case outward = 1

        public var description: String {
            switch (self) {
            case .inward:
                return "Inward"
            case .outward:
                return "Outward"
            }
        }
    }

    public struct Transition: Codable, Hashable {
        public var color = RGB()
        public var position: CGFloat = 0x21 / 0xBB8

        public init(color: RGB, position: CGFloat) {
            self.color = color
            self.position = position
        }
    }

    public struct Point: Hashable, Codable {
        public var x: CGFloat = 0
        public var y: CGFloat = 0

        public init() {
            x = 0
            y = 0
        }

        public init(x: CGFloat, y: CGFloat) {
            self.x = x
            self.y = y
        }
    }

    public enum Mode: Int, Codable, CustomStringConvertible, CaseIterable {
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

// MARK: - Codable Extension

extension Key.Effect: Codable {}

// MARK: - Hash Extension

extension Key.Effect: Hashable {}

//extension Effect: Hashable {
//    func dataEqual(with effect: KeyEffect) -> Bool {
//        return self.start == effect.start &&
//        self.transitions == effect.transitions &&
//        self.waveActive == effect.waveActive &&
//        self.direction == effect.direction &&
//        self.control == effect.control &&
//        self.pulse == effect.pulse &&
//        self.duration == effect.duration &&
//        self.origin == effect.origin
//    }
//}
//
