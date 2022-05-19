//
//  Interface.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/18/22.
//

import Combine
import ComposableArchitecture
import IOKit.hid

public struct DeviceScanner {
    public struct Error: Swift.Error, Equatable {
        public let error: NSError?

        public init(_ error: Swift.Error?) {
            self.error = error as NSError?
        }
    }

    public enum Event: Equatable {
        case didDiscover(_ device: Device, error: Error?)
        case didRemove(_ device: Device, error: Error?)
    }

    var create: (AnyHashable, CFRunLoop, CFRunLoopMode) -> Effect<Event, Never> = { _,_,_ in .none }

    var destroy: (AnyHashable) -> Effect<Never, Never> = { _ in .none }

    var scan: (AnyHashable) -> Effect<Never, Never> = { _ in .none }

    var retrieveDevices: (AnyHashable) -> Set<Device>? = { _ in .none }

    // MARK: - Concrete

    public func create(id: AnyHashable) -> Effect<Event, Never> {
        create(id, CFRunLoopGetMain(), .defaultMode)
    }

    public func destroy(id: AnyHashable) -> Effect<Never, Never> {
        destroy(id)
    }

    public func scan(id: AnyHashable) -> Effect<Never, Never> {
        scan(id)
    }

    public func retrieveDevices(id: AnyHashable) -> Set<Device>? {
        retrieveDevices(id)
    }
}
