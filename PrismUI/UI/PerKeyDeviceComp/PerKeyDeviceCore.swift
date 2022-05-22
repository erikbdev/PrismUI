//
//  PerKeyDeviceCore.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/19/22.
//

import ComposableArchitecture
import PrismClient
import CoreGraphics

// This will control the interaction between both the settings and key selection

struct PerKeyDeviceState: Equatable {
    var keyboardState = PerKeyKeyboardState()
    var settingsState = PerKeySettingsState()

//    init(model: Models) {
//        keyboardState = .init(model: model)
//    }
//    var settingsState: PerKeySettingsState {
//        get {
//            let selectedKeys = perKeyKeyboardState.keys.enumerated().filter { element in
//                perKeyKeyboardState.selectedKeys.contains(element.offset)
//            }
//
//            if let firstKey = selectedKeys.first?.element {
//                let allSatisfy = selectedKeys.allSatisfy { element in
//                    element.element.sameEffect(as: firstKey)
//                }
//
//                if allSatisfy {
//                    // Set Current PerKeySettingsState
//                    let mode = firstKey.mode
//                    switch mode {
//                    case .steady:
//                        return PerKeySettingsState(
//                            mode: mode,
//                            steady: firstKey.main.hsb
//                        )
//                    case .colorShift:
//                        if let effect = firstKey.effect {
//                            return PerKeySettingsState(
//                                mode: mode,
//                                speed: CGFloat(effect.duration),
//                                gradientStyle: .gradient,
//                                colorSelectors: effect.transitions
//                                    .compactMap({ ColorSelector(rgb: $0.color, position: $0.position) }),
//                                waveActive: effect.waveActive,
//                                direction: effect.direction,
//                                control: effect.control,
//                                pulse: CGFloat(effect.pulse),
//                                origin: effect.origin
//                            )
//                        }
//                    case .breathing:
//                        if let effect = firstKey.effect {
//                            return PerKeySettingsState(
//                                mode: mode,
//                                speed: CGFloat(effect.duration),
//                                gradientStyle: .breathing,
//                                colorSelectors: effect.transitions
//                                    .enumerated()
//                                    .filter({ $0.offset % 2 == 0 })
//                                    .compactMap({ $0.element })
//                                    .compactMap({ ColorSelector(rgb: $0.color, position: $0.position) })
//                            )
//                        }
//                    case .reactive:
//                        return PerKeySettingsState(
//                            mode: mode,
//                            speed: CGFloat(firstKey.duration),
//                            active: firstKey.active.hsb,
//                            rest: firstKey.main.hsb
//                        )
//                    default:
//                        return PerKeySettingsState(mode: mode)
//                    }
//                } else {
//                    return PerKeySettingsState(mode: .mixed)
//                }
//            }
//
//            return PerKeySettingsState()
//        }
//        set {
//            // any changes to settings are reflected to the keys selected, if any
//            print("New mode: \(newValue.mode)")
//        }
//    }
}

enum PerKeyDeviceAction: Equatable {
    case onAppear
    case perKeyKeyboard(PerKeyKeyboardAction)
    case perKeySettings(PerKeySettingsAction)
    // TODO: Use this to communicate to another part of the view.
}

struct PerKeyDeviceEnvironment {
    let device: Device
    // Set the controller here rather than in the Device class
//    let perKeyController: Controller
}

let perKeyDeviceReducer = Reducer<PerKeyDeviceState, PerKeyDeviceAction, PerKeyDeviceEnvironment>.combine(
    perKeySettingsReducer.pullback(
        state: \.settingsState,
        action: /PerKeyDeviceAction.perKeySettings,
        environment: { _ in .init() }
    ),
    perKeyKeyboardReducer.pullback(
        state: \.keyboardState,
        action: /PerKeyDeviceAction.perKeyKeyboard,
        environment: { _ in .init() }
    ),
    .init { state, action, environment in
        switch action {
        case .onAppear:
            print("Device Core: PerKeyDevice appeared!")
        case .perKeyKeyboard(.onAppear):
            state.keyboardState.model = environment.device.model
        case .perKeyKeyboard(.selectionChanged):
//            let selectedKeys = state.keyboardState.selected.compactMap { id in
//                state.keyboardState.keys[id: UInt16(id)]?.key
//            }
//
//            if let firstKey = selectedKeys.first {
//                let allSatisfy = selectedKeys.allSatisfy { key in
//                    key.sameEffect(as: firstKey)
//                }
//
//                if allSatisfy {
//                    // Set Current
//                    let mode = firstKey.mode
//                    switch mode {
//                    case .steady:
//                        state.settingsState.mode = mode
//                        state.settingsState.steady = firstKey.main.hsb
//                    case .colorShift:
//                        if let effect = firstKey.effect {
//                            state.settingsState.mode = mode
//                            state.settingsState.speed = CGFloat(effect.duration)
//                            state.settingsState.gradientStyle = .gradient
//                            state.settingsState.colorSelectors = effect.transitions.compactMap({ ColorSelector(rgb: $0.color, position: $0.position) })
//                            state.settingsState.waveActive = effect.waveActive
//                            state.settingsState.direction = effect.direction
//                            state.settingsState.control = effect.control
//                            state.settingsState.pulse = CGFloat(effect.pulse)
//                            state.settingsState.origin = effect.origin
//                        }
//                    case .breathing:
//                        if let effect = firstKey.effect {
//                            state.settingsState.mode = mode
//                            state.settingsState.speed = CGFloat(effect.duration)
//                            state.settingsState.gradientStyle = .breathing
//                            state.settingsState.colorSelectors = effect.transitions
//                                .enumerated()
//                                .filter({ $0.offset % 2 == 0 })
//                                .compactMap({ $0.element })
//                                .compactMap({ ColorSelector(rgb: $0.color, position: $0.position) })
//                        }
//                    case .reactive:
//                        state.settingsState.mode = mode
//                        state.settingsState.speed = CGFloat(firstKey.duration)
//                        state.settingsState.active = firstKey.active.hsb
//                        state.settingsState.rest = firstKey.main.hsb
//                    default:
//                        state.settingsState.mode = mode
//                    }
//                } else {
//                    state.settingsState.mode = .mixed
//                }
//            }
            break
        case .perKeyKeyboard(.loadKeys):
            break
        case .perKeyKeyboard(.key(id: let id, action: let action)):
            break
        case .perKeySettings(let action):
//            print("Device Core: Settings changed")
            break
        }
        return .none
    }
)
