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

struct PerKeyDevice {
    struct State: Equatable {
        var keyboardState = PerKeyKeyboardCore.State()
        var settingsState = PerKeySettingsCore.State()
        @BindableState var mouseMode = MouseMode.single
    }

    enum Action: BindableAction, Equatable {
        case onAppear
        case touchedOutside
        case refreshSettings
        case perKeyKeyboard(PerKeyKeyboardCore.Action)
        case perKeySettings(PerKeySettingsCore.Action)
        case binding(BindingAction<PerKeyDevice.State>)
    }

    struct Environment {
        let device: Device
        // Set the controller here rather than in the Device class
//        let perKeyController: Controller
    }

    static let reducer = Reducer<PerKeyDevice.State, PerKeyDevice.Action, PerKeyDevice.Environment>.combine(
        PerKeySettingsCore.reducer.pullback(
            state: \.settingsState,
            action: /PerKeyDevice.Action.perKeySettings,
            environment: { _ in .init() }
        ),
        PerKeyKeyboardCore.reducer.pullback(
            state: \.keyboardState,
            action: /PerKeyDevice.Action.perKeyKeyboard,
            environment: { _ in .init() }
        ),
        .init { state, action, environment in
            switch action {
            case .onAppear:
                print("Device Core: PerKeyDevice appeared!")
            case .perKeyKeyboard(.onAppear):
                state.keyboardState.model = environment.device.model
            case .refreshSettings:
                let selectedKeys = state.keyboardState.keys.filter({ $0.selected }).compactMap({ $0.key })

                if let firstKey = selectedKeys.first {
                    state.settingsState.enabled = true

                    let allSatisfy = selectedKeys.allSatisfy { key in
                        key.sameEffect(as: firstKey)
                    }

                    if allSatisfy {
                        // Set Current
                        let mode = firstKey.mode
                        switch mode {
                        case .steady:
                            state.settingsState.mode = mode
                            state.settingsState.steady = firstKey.main.hsb
                        case .colorShift:
                            if let effect = firstKey.effect {
                                state.settingsState.mode = mode
                                state.settingsState.speed = CGFloat(effect.duration)
                                state.settingsState.gradientStyle = .gradient
                                state.settingsState.colorSelectors = effect.transitions.compactMap({ ColorSelector(rgb: $0.color, position: $0.position) })
                                state.settingsState.waveActive = effect.waveActive
                                state.settingsState.direction = effect.direction
                                state.settingsState.control = effect.control
                                state.settingsState.pulse = CGFloat(effect.pulse)
                                state.settingsState.origin = effect.origin
                            }
                        case .breathing:
                            if let effect = firstKey.effect {
                                state.settingsState.mode = mode
                                state.settingsState.speed = CGFloat(effect.duration)
                                state.settingsState.gradientStyle = .breathing
                                state.settingsState.colorSelectors = effect.transitions
                                    .enumerated()
                                    .filter({ $0.offset % 2 == 0 })
                                    .compactMap({ $0.element })
                                    .compactMap({ ColorSelector(rgb: $0.color, position: $0.position) })
                            }
                        case .reactive:
                            state.settingsState.mode = mode
                            state.settingsState.speed = CGFloat(firstKey.duration)
                            state.settingsState.active = firstKey.active.hsb
                            state.settingsState.rest = firstKey.main.hsb
                        default:
                            state.settingsState.mode = mode
                        }
                    } else {
                        state.settingsState.mode = .mixed
                    }
                } else {
                    state.settingsState.enabled = false
                    state.settingsState.mode = .steady
                }
            case .perKeyKeyboard(.key(id: let identifier, action: .toggleSelected)):
                // If a key is changed, either select all keys that are similar to it or not.
                if state.mouseMode == .same, let keyState = state.keyboardState.keys[id: identifier] {
                    for id in state.keyboardState.keys.map({ $0.id }) {
                        let tempKey = state.keyboardState.keys[id: id]!.key
                        let sameEffect = keyState.key.sameEffect(as: tempKey)
                        if keyState.selected {
                            state.keyboardState.keys[id: id]?.selected = sameEffect
                        } else {
                            if sameEffect {
                                state.keyboardState.keys[id: id]?.selected = false
                            }
                        }
                    }
                }
                return .init(value: .refreshSettings)
            case .perKeyKeyboard(_):
                break
            case .perKeySettings(.updatedValues(let touchUp)):
                switch state.settingsState.mode {
                case .steady:
                    for keyState in state.keyboardState.keys.filter({ $0.selected }) {
                        state.keyboardState.keys[id: keyState.id]?.key.mode = .steady
                        state.keyboardState.keys[id: keyState.id]?.key.main = state.settingsState.steady.rgb
                    }
                case .colorShift:
                    let transitions = state.settingsState.colorSelectors.compactMap({ KeyEffect.PerKeyTransition(color: $0.rgb, position: $0.position) })
                        .sorted(by: { $0.position < $1.position })

                    guard transitions.count > 0 else { return .none }

                    var effect = KeyEffect(id: 0, transitions: transitions)
                    effect.start = transitions[0].color
                    effect.duration = UInt16(state.settingsState.speed)
                    effect.waveActive = state.settingsState.waveActive
                    effect.direction = state.settingsState.direction
                    effect.control = state.settingsState.control
                    effect.origin = state.settingsState.origin
                    effect.pulse = UInt16(state.settingsState.pulse)

                    for id in state.keyboardState.keys.filter({ $0.selected }).map({ $0.id }) {
                        state.keyboardState.keys[id: id]?.key.mode = .colorShift
                        state.keyboardState.keys[id: id]?.key.effect = effect
                        state.keyboardState.keys[id: id]?.key.main = effect.start
                    }
                case .breathing:
                    let transitions = state.settingsState.colorSelectors.compactMap({ KeyEffect.PerKeyTransition(color: $0.rgb, position: $0.position) })
                        .sorted(by: { $0.position < $1.position })

                    guard transitions.count > 0 else { return .none }

                    var effect = KeyEffect(id: 0, transitions: transitions)
                    effect.start = transitions[0].color
                    effect.duration = UInt16(state.settingsState.speed)
                    effect.waveActive = state.settingsState.waveActive
                    effect.direction = state.settingsState.direction
                    effect.control = state.settingsState.control
                    effect.origin = state.settingsState.origin
                    effect.pulse = UInt16(state.settingsState.pulse)

                    for id in state.keyboardState.keys.filter({ $0.selected }).map({ $0.id }) {
                        state.keyboardState.keys[id: id]?.key.mode = .colorShift
                        state.keyboardState.keys[id: id]?.key.effect = effect
                        state.keyboardState.keys[id: id]?.key.main = effect.start
                    }
//                case .reactive:
//                case .disabled:
                default:
                    break
                }
                
            case .perKeySettings(_):
                break
            case .binding(_):
                break
            case .touchedOutside:
                for i in state.keyboardState.keys.map({ $0.id }) {
                    state.keyboardState.keys[id: i]?.selected = false
                }
                return .init(value: .refreshSettings)
            }
            return .none
        }
    )
        .binding()

    // MARK: - Mouse Modes

    enum MouseMode: String, CaseIterable {
        case single = "cursorarrow"
        case same = "cursorarrow.rays"
        case rectangle = "rectangle.dashed"
    }
}
