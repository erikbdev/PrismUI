//
//  Device.swift
//  PrismKit
//
//  Created by Erik Bautista on 9/17/21.
//

import Foundation
import IOKit

public struct Device {
    public let id: Int
    public let name: String
    public let model: Models

    private let controller: Controller?

    public init(
        hidDevice: IOHIDDevice
    ) throws {
        id = try hidDevice.getProperty(key: kIOHIDLocationIDKey) as Int
        name = try hidDevice.getProperty(key: kIOHIDProductKey) as String

        let vendorId = try hidDevice.getProperty(key: kIOHIDVendorIDKey) as Int
        let productId = try hidDevice.getProperty(key: kIOHIDProductIDKey) as Int
        let versionNumber = try hidDevice.getProperty(key: kIOHIDVersionNumberKey) as Int
        let primaryUsagePage = try hidDevice.getProperty(key: kIOHIDPrimaryUsagePageKey) as Int

        model = Models.allCases.first(where: {
            $0.vendorId == vendorId &&
            $0.productId == productId &&
            $0.versionNumber == versionNumber &&
            $0.primaryUsagePage == primaryUsagePage
        }) ?? .unknown

        if model == .perKey || model == .perKeyGS65 {
            controller = PerKeyController(device: hidDevice, isLongKeyboard: model == .perKey)
        } else {
            controller = nil
        }
    }

    public init(
        hidDevice: HIDCommunication,
        id: Int,
        name: String,
        model: Models
    ) {
        self.id = id
        self.name = name
        self.model = model

        if model == .perKey || model == .perKeyGS65 {
            controller = PerKeyController(device: hidDevice, isLongKeyboard: model == .perKey)
        } else {
            controller = nil
        }
    }

    public func update(data: Any, force: Bool) {
        if let controller = controller {
            controller.update(data: data, force: force)
        } else {
            print("This device does not have a controller: \(model)")
        }
    }
}

extension Device: Identifiable { }

extension Device: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(model)
    }

    public static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.id == rhs.id
    }
}
