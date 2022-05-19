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
    public var properties: Properties?
    public let name: String

    internal let device: IOHIDDevice
    internal let vendorId: Int
    internal let productId: Int
    internal let versionNumber: Int
    internal let primaryUsagePage: Int
    internal var controller: Controller?

    public init(hidDevice: IOHIDDevice) throws {
        self.device = hidDevice
        id = try hidDevice.getProperty(key: kIOHIDLocationIDKey)
        name = try hidDevice.getProperty(key: kIOHIDProductKey)
        vendorId = try hidDevice.getProperty(key: kIOHIDVendorIDKey)
        productId = try hidDevice.getProperty(key: kIOHIDProductIDKey)
        versionNumber = try hidDevice.getProperty(key: kIOHIDVersionNumberKey)
        primaryUsagePage = try hidDevice.getProperty(key: kIOHIDPrimaryUsagePageKey)

        if model == .perKey || model == .perKeyGS65 {
            properties = PerKeyProperties()
            controller = PerKeyController(device: hidDevice, model: model, properties: properties as! PerKeyProperties)
        } else {
            // TODO: Handle devices with no controllers, meaning not supported
        }
    }

    public var model: Models {
        let product = Models.allCases.first(where: {
            $0.vendorId == self.vendorId &&
                $0.productId == self.productId &&
                $0.versionNumber == self.versionNumber &&
                $0.primaryUsagePage == self.primaryUsagePage
        })
        return product ?? .unknown
    }

    public func update(data: [Any], force: Bool) {
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
        hasher.combine(device)
    }

    public static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.id == rhs.id
    }
}
