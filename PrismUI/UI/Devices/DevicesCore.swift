//
//  DevicesCore.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/17/22.
//

import var AppKit.NSApplication.NSApp
import AppKit.NSSplitViewController

import ComposableArchitecture
import PrismKit

struct DevicesState: Equatable {
    var devices: IdentifiedArrayOf<SSDevice> = []
}

enum DevicesAction: Equatable {
    case onAppear
    case toggleSidebar
    case device(id: SSDevice.ID, action: DeviceAction)
    case devicesManager(PrismDeviceManager.Action)
}

struct DevicesEnvironment {
    var devicesManager: PrismDeviceManager
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
                environment.devicesManager.create(id: DevicesManagerId())
                    .map(DevicesAction.devicesManager),
                environment.devicesManager.scan(id: DevicesManagerId())
                    .fireAndForget()
            )
        case let .devicesManager(delegate):
            switch delegate {
            case .didDiscover(let device, error: let error):
                if let device = try? SSDevice(device: device) {
                    state.devices.append(device)
                }
            case .didRemove(let device, error: let error):
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

extension SSDevice: Identifiable {
    
}
