//
//  HIDDevice+GetProperty.swift
//  PrismKit
//
//  Created by Erik Bautista on 7/20/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation
import IOKit.hid

extension IOHIDDevice {

    enum Error: Swift.Error {
        case failedToFindProperty
        case mismatchPropertyType(expected: String, actual: String)
    }

    func getProperty<T>(key: String) throws -> T {

        guard let value = IOHIDDeviceGetProperty(self, key as CFString) else {
            throw Error.failedToFindProperty
        }

        guard let typedValue = value as? T else {
            throw Error.mismatchPropertyType(expected: String(describing: T.self), actual: "\(type(of: value))")
        }

        return typedValue
    }
}
