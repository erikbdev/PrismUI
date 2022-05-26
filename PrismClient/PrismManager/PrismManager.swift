//
//  PrismManager.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/18/22.
//

import Combine
import ComposableArchitecture
import IOKit.hid

public struct PrismManager {
    var create: (AnyHashable, CFRunLoop, CFRunLoopMode) -> Effect<Action, Never> = { _,_,_ in .none }

    var destroy: (AnyHashable) -> Effect<Never, Never> = { _ in .none }

    var scan: (AnyHashable) -> Effect<Never, Never> = { _ in .none }

    var retreiveDevices: (AnyHashable) -> [PrismDevice.State] = { _ in [] }

    var deviceEnvironment: (AnyHashable, Int) -> PrismDevice.Environment? = { _,_ in nil }

    public func create(id: AnyHashable) -> Effect<Action, Never> {
        create(id, CFRunLoopGetCurrent(), .defaultMode)
    }

    public func destroy(id: AnyHashable) -> Effect<Never, Never> {
        destroy(id)
    }

    public func scan(id: AnyHashable) -> Effect<Never, Never> {
        scan(id)
    }

    public func retreiveDevices(id: AnyHashable) -> [PrismDevice.State] {
        retreiveDevices(id)
    }

    public func deviceEnvironment(id: AnyHashable, deviceId: Int) -> PrismDevice.Environment? {
        deviceEnvironment(id, deviceId)
    }
}

extension PrismManager {
    public enum Action: Equatable {
        case didDiscover(PrismDevice.State)
        case didRemove(PrismDevice.State)
    }
}
