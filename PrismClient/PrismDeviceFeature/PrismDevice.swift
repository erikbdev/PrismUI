//
//  PrismDevice.swift
//  PrismClient
//
//  Created by Erik Bautista on 5/24/22.
//

import IOKit.hid
import ComposableArchitecture

public struct PrismDevice {}

// MARK: PrismDevice - State

extension PrismDevice {
    public struct State {
        public let identifier: Int
        public var name: String
        public let model: Model
        public let device: HIDCommunication
    }
}

extension PrismDevice.State: Hashable {
    public static func == (lhs: PrismDevice.State, rhs: PrismDevice.State) -> Bool {
        lhs.identifier == rhs.identifier &&
        lhs.name == rhs.name &&
        lhs.model == rhs.model
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(name)
        hasher.combine(model)
    }
}

extension PrismDevice.State: Identifiable {
    public var id: Int {
        identifier
    }
}

// MARK: PrismDevice - Action

//extension PrismDevice {
//    public enum Action: Equatable { }
//}

// MARK: PrismDevice - Environment

//extension PrismDevice {
//    public struct Environment {
//        var hidDevice: HIDCommunication
//        var updateDevice: (Data, Bool) -> Effect<Never, Never> = { _,_ in .none }
//
//        public func updateDevice(data: Data, forced: Bool) -> Effect<Never, Never> {
//            updateDevice(data, forced)
//        }
//    }
//}

// MARK: PrismDevice - Models

extension PrismDevice {
    public enum Model: CaseIterable {
        case perKey
        case perKeyShort
        case threeRegion
        case unknown
    }
}

// MARK: PrismDevice - Model + Extension

extension PrismDevice.Model {
    var vendorId: Int {
        switch self {
        case .perKey, .perKeyShort: return 0x1038
        case .threeRegion: return 0x1770
        default: return 0
        }
    }

    var productId: Int {
        switch self {
        case .perKey, .perKeyShort: return 0x1122
        case .threeRegion: return 0xff00
        default: return 0
        }
    }

    var versionNumber: Int {
        switch self {
        case .perKey: return 0x230
        case .perKeyShort: return 0x229
        case .threeRegion: return 0x110
        default: return 0
        }
    }

    var primaryUsagePage: Int {
        switch self {
        case .perKey, .perKeyShort: return 0xffc0
        case .threeRegion: return 0xffa0
        default: return 0
        }
    }
}

extension PrismDevice.Model {
    func productInformation() -> IOHIDManager.ProductInformation {
        return .init(
            vendorId: vendorId,
            productId: productId,
            versionNumber: versionNumber,
            primaryUsagePage: primaryUsagePage
        )
    }
}

extension PrismDevice.Model: CustomStringConvertible {
    public var description: String {
        switch self {
        case .perKey: return "Per Key Keyboard"
        case .perKeyShort: return "Short Per Key Keyboard"
        case .threeRegion: return "Three Region Keyboard"
        default: return "Unknown"
        }
    }
}

