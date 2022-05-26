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

struct DevicesCore {
    struct State: Equatable {
        var devices: IdentifiedArrayOf<PrismDevice.State> = []
    }

    enum Action: Equatable {
        case onAppear
        case toggleSidebar
        case devicesManager(PrismManager.Action)
    }

    struct Environment {
        var mainQueue: AnySchedulerOf<DispatchQueue>
        var backgroundQueue: AnySchedulerOf<DispatchQueue>
        let prismManager: PrismManager
    }

    static let reducer = Reducer<DevicesCore.State, DevicesCore.Action, DevicesCore.Environment>.combine(
        .init { state, action, environment in
            struct DevicesManagerId: Hashable {}
            switch action {
            case .onAppear:
                return .merge(
                    environment.prismManager.create(id: DevicesManagerId())
                        .map(DevicesCore.Action.devicesManager),
                    environment.prismManager.scan(id: DevicesManagerId())
                        .fireAndForget()
                )
            case .toggleSidebar:
                NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
            case .devicesManager(let delegate):
                switch delegate {
                case .didDiscover(let device):
                    state.devices.append(device)
                case .didRemove(let device):
                    state.devices.remove(device)
                }
            }
            return .none
        }
    )
}
