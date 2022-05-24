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

    public var effect = Key.Effect()

    public init(name: String, region: UInt8, keycode: UInt8) {
        self.name = name
        self.region = region
        self.keycode = keycode
    }
}

extension Key: Hashable {}

extension Key: Codable {}
