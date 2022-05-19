//
//  IOHIDDevice+Write.swift
//  PrismKit
//
//  Created by Erik Bautista on 7/20/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation

extension IOHIDDevice {
    public func write(data: Data) -> IOReturn {

        guard IOHIDDeviceOpen(self, IOOptionBits(kIOHIDOptionsTypeNone)) == kIOReturnSuccess else {
            print("Could not open usb port")
            return kIOReturnNotOpen
        }

        let returnValue = IOHIDDeviceSetReport(
            self,
            kIOHIDReportTypeOutput,
            CFIndex(0),
            [UInt8](data),
            data.count
        )

        guard returnValue == kIOReturnSuccess else {
            print("Could not write report")
            return returnValue
        }

        guard IOHIDDeviceClose(self, IOOptionBits(kIOHIDOptionsTypeNone)) == kIOReturnSuccess else {
            print("Could not close usb port")
            return kIOReturnStillOpen
        }

        return kIOReturnSuccess
    }
}
