//
//  SSKeyEffectStruct.swift
//  PrismKit
//
//  Created by Erik Bautista on 12/24/21.
//

import Foundation
import Combine


public struct KeyEffect {

    // MARK: Identifier
    // If id = -1, that means the identifier has not been set yet.
    public var id: UInt8

    // MARK: Transitions

    public var transitions: [SSPerKeyTransition]

    // MARK: Start color

    public var start = RGB()

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
    public var origin = PerKeyPoint()
    public var pulse: UInt16 = 100

    public init(id: UInt8, transitions: [SSPerKeyTransition]) {
        self.id = id
        self.transitions = transitions
        self.start = transitions.first?.color ?? RGB()
    }
}

public extension KeyEffect {
    enum Direction: UInt8, CaseIterable, CustomStringConvertible, Codable {
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

    enum Control: UInt8, CaseIterable, CustomStringConvertible, Codable {
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

    struct SSPerKeyTransition: Codable, Hashable {
        public var color = RGB()
        public var position: CGFloat = 0x21 / 0xBB8

        public init(color: RGB, position: CGFloat) {
            self.color = color
            self.position = position
        }
    }

    struct PerKeyPoint: Hashable, Codable {
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
}

// MARK: - Codable Extension

extension KeyEffect: Codable {}

// MARK: - Hash Extension

extension KeyEffect: Hashable {
    func dataEqual(with effect: KeyEffect) -> Bool {
        return self.start == effect.start &&
        self.transitions == effect.transitions &&
        self.waveActive == effect.waveActive &&
        self.direction == effect.direction &&
        self.control == effect.control &&
        self.pulse == effect.pulse &&
        self.duration == effect.duration &&
        self.origin == effect.origin
    }
}
