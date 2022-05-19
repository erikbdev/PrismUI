//
//  Models.swift
//  PrismKit
//
//  Created by Erik Bautista on 9/17/21.
//

import IOKit.hid

public enum Models: CaseIterable {

    case perKey
    case perKeyGS65
    case threeRegion
    case unknown

    public func productInformation() -> IOHIDManager.ProductInformation {
        return .init(vendorId: vendorId,
                     productId: productId,
                     versionNumber: versionNumber,
                     primaryUsagePage: primaryUsagePage)
    }

    public var vendorId: Int {
        switch self {
        case .perKey, .perKeyGS65: return 0x1038
        case .threeRegion: return 0x1770
        default: return 0
        }
    }

    public var productId: Int {
        switch self {
        case .perKey, .perKeyGS65: return 0x1122
        case .threeRegion: return 0xff00
        default: return 0
        }
    }

    public var versionNumber: Int {
        switch self {
        case .perKey: return 0x230
        case .perKeyGS65: return 0x229
        case .threeRegion: return 0x110
        default: return 0
        }
    }

    public var primaryUsagePage: Int {
        switch self {
        case .perKey, .perKeyGS65: return 0xffc0
        case .threeRegion: return 0xffa0
        default: return 0
        }
    }
}
