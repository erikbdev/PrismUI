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
    case device(id: Device.ID, action: DeviceAction)
    case devicesManager(DeviceScanner.Event)
}

struct DevicesEnvironment {
    var deviceScanner: DeviceScanner
}

let devicesReducer = Reducer<DevicesState, DevicesAction, DevicesEnvironment>.combine(
    deviceReducer.forEach(
        state: \DevicesState.devices,
        action: /DevicesAction.device(id:action:),
        environment: { _ in
            DeviceEnvironment()
        }
    ),
    Reducer { state, action, environment in
        struct DevicesManagerId: Hashable {}

        switch action {
        case .onAppear:
            return .merge(
                environment.deviceScanner.create(id: DevicesManagerId())
                    .map(DevicesAction.devicesManager),
                environment.deviceScanner.scan(id: DevicesManagerId())
                    .fireAndForget()
            )
        case let .devicesManager(delegate):
            switch delegate {
            case .didDiscover(let device, error: let error):
                state.devices.append(device)
            case .didRemove(let device, error: let error):
                state.devices.remove(device)
                break
            }
        case .device(id: let id, action: let action):
            break
        case .toggleSidebar:
            NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        }

        return .none
    }
)

