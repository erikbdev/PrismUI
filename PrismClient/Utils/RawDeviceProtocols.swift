//
//  RawDeviceProtocols.swift
//  PrismKit
//
//  Created by Erik Bautista on 7/20/20.
//  Copyright © 2020 ErrorErrorError. All rights reserved.
//

import Foundation
import IOKit.hid

public protocol WriteDevice {
    func write(data: Data) -> IOReturn
}

public protocol FeatureReportDevice {
    func sendFeatureReport(data: Data) -> IOReturn
}

typealias HIDCommunication = WriteDevice & FeatureReportDevice

extension IOHIDDevice: HIDCommunication {}
