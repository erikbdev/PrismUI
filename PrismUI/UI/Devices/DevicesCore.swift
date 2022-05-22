//
//  DevicesCore.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/17/22.
//

import var AppKit.NSApplication.NSApp
import AppKit.NSSplitViewController

import ComposableArchitecture
import PrismClient

struct DevicesState: Equatable {
    var devices: IdentifiedArrayOf<Device> = []
}

enum DevicesAction: Equatable {
    case onAppear
    case toggleSidebar
    case devicesManager(DeviceScanner.Event)
}

struct DevicesEnvironment {
    let deviceScanner: DeviceScanner
}

let devicesReducer = Reducer<DevicesState, DevicesAction, DevicesEnvironment>.combine(
    .init { state, action, environment in
        struct DevicesManagerId: Hashable {}
        switch action {
        case .onAppear:
            return .merge(
                environment.deviceScanner.create(id: DevicesManagerId())
                    .map(DevicesAction.devicesManager),
                environment.deviceScanner.scan(id: DevicesManagerId())
                    .fireAndForget()
            )
        case .devicesManager(let delegate):
            switch delegate {
            case .didDiscover(let device, error: let error):
                state.devices.append(device)
            case .didRemove(let device, error: let error):
                state.devices.remove(device)
            }
        case .toggleSidebar:
            NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        }

        return .none
    }
)
