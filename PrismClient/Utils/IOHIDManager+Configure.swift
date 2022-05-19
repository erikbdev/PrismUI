//
//  IOHIDManager+Configure.swift
//  PrismKit
//
//  Created by Erik Bautista on 7/21/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation
import IOKit.hid

public extension IOHIDManager {

    struct ProductInformation {
        public let vendorId: Int
        public let productId: Int
        public let versionNumber: Int
        public let primaryUsagePage: Int

        public init(vendorId: Int, productId: Int, versionNumber: Int, primaryUsagePage: Int) {
            self.vendorId = vendorId
            self.productId = productId
            self.versionNumber = versionNumber
            self.primaryUsagePage = primaryUsagePage
        }
    }

    func setDeviceMatchingMultiple(products: [ProductInformation]) {
        var builder = [[String: Any]]()

        for product in products {
            builder.append([
                kIOHIDProductIDKey: product.productId,
                kIOHIDVendorIDKey: product.vendorId,
                kIOHIDVersionNumberKey: product.versionNumber,
                kIOHIDPrimaryUsagePageKey: product.primaryUsagePage
            ])
        }

        IOHIDManagerSetDeviceMatchingMultiple(self, builder as CFArray)
    }

    func scheduleWithRunLoop(with runLoop: CFRunLoop, runLoopMode: CFRunLoopMode = .defaultMode) {
        IOHIDManagerScheduleWithRunLoop(self, runLoop, runLoopMode.rawValue)
    }

    func open(options: IOOptionBits = IOOptionBits(kIOHIDOptionsTypeNone)) {
        IOHIDManagerOpen(self, options)
    }

    func close() {
        IOHIDManagerClose(self, IOOptionBits(kIOHIDOptionsTypeNone))
    }

    func registerDeviceMatchingCallback(_ callback: @escaping IOHIDDeviceCallback, context: UnsafeMutableRawPointer?) {
        IOHIDManagerRegisterDeviceMatchingCallback(self, callback, context)
    }

    func registerDeviceRemovalCallback(_ callback: @escaping IOHIDDeviceCallback, context: UnsafeMutableRawPointer?) {
        IOHIDManagerRegisterDeviceRemovalCallback(self, callback, context)
    }

    func copyDevices() -> CFSet? {
        IOHIDManagerCopyDevices(self)
    }
}
