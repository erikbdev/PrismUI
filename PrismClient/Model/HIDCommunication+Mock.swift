//
//  HIDCommunication+Mock.swift
//  PrismClient
//
//  Created by Erik Bautista on 5/19/22.
//

import Foundation

public struct HIDCommunicationMock: HIDCommunication {
    public func write(data: Data) -> IOReturn {
        kIOReturnSuccess
    }

    public func sendFeatureReport(data: Data) -> IOReturn {
        kIOReturnSuccess
    }
}

public extension HIDCommunicationMock {
    static let mock = HIDCommunicationMock()
}
