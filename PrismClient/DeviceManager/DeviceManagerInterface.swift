//
//  Interface.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/19/22.
//

import ComposableArchitecture

public struct DeviceManager {
    public enum Event: Equatable {  }

    var create: (AnyHashable, Device) -> Effect<Event, Never> = { _,_  in .none }
    var update: (AnyHashable, Any) -> Effect<Never, Never> = { _,_  in .none }

    public func create(id: AnyHashable, device: Device) -> Effect<Event, Never> {
        create(id, device)
    }

    public func update(id: AnyHashable, data: Any) -> Effect<Never, Never> {
        update(id, data)
    }
}
