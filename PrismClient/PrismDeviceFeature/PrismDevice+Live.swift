//
//  PrismDevice+Live.swift
//  PrismClient
//
//  Created by Erik Bautista on 5/24/22.
//

import ComposableArchitecture
import IOKit

extension PrismDevice.State {
    public static func live(from device: IOHIDDevice) -> Self {
        let productID: Int? = try? device.getProperty(key: kIOHIDProductIDKey)
        let vendorID: Int? = try? device.getProperty(key: kIOHIDVendorIDKey)
        let versionNumber: Int? = try? device.getProperty(key: kIOHIDVersionNumberKey)
        let primaryUsagePage: Int? = try? device.getProperty(key: kIOHIDPrimaryUsagePageKey)

        return .init(
            identifier: (try? device.getProperty(key: kIOHIDLocationIDKey)) ?? -1,
            name: (try? device.getProperty(key: kIOHIDProductKey)) ?? "Unknown",
            model: .allCases.first(
                where: { model in
                    model.productId == productID &&
                    model.vendorId == vendorID &&
                    model.versionNumber == versionNumber &&
                    model.primaryUsagePage == primaryUsagePage
                }) ?? .unknown,
            device: device
        )
    }
}
