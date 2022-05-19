//
//  IOHIDDevice+FeatureReport.swift
//  PrismKit
//
//  Created by Erik Bautista on 7/20/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation
import IOKit

extension IOHIDDevice {
    public func sendFeatureReport(data: Data) -> IOReturn {
        var returnValue = IOHIDDeviceOpen(self, IOOptionBits(kIOHIDOptionsTypeNone))
        guard returnValue == kIOReturnSuccess else {
            Log.error("Could not open usb port: \(String(cString: mach_error_string(returnValue)))")
            return kIOReturnNotOpen
        }

        returnValue = IOHIDDeviceSetReport(
            self,
            kIOHIDReportTypeFeature,
            CFIndex(data[0]),
            [UInt8](data),
            data.count
        )

        Thread.sleep(forTimeInterval: 0.05)

        guard returnValue == kIOReturnSuccess else {
            Log.error("Could send feature report: \(String(cString: mach_error_string(returnValue)))")
            return returnValue
        }

        returnValue = IOHIDDeviceClose(self, IOOptionBits(kIOHIDOptionsTypeNone))
        guard returnValue  == kIOReturnSuccess else {
            Log.error("Could not close usb port: \(String(cString: mach_error_string(returnValue)))")
            return returnValue
        }

        return returnValue
    }
}
