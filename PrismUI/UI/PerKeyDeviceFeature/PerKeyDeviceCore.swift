//
//  PerKeyDeviceCore.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/19/22.
//

import ComposableArchitecture
import PrismClient

// This will control the interaction between both the settings and key selection

struct PerKeyDeviceCore {
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
        case binding(BindingAction<PerKeyDeviceCore.State>)
    }

    struct Environment {
        var mainQueue: AnySchedulerOf<DispatchQueue>
        var backgroundQueue: AnySchedulerOf<DispatchQueue>

        let device: Device
        // Set the controller here rather than in the Device class
//        let perKeyController: PerKeyController
    }

    static let reducer = Reducer<PerKeyDeviceCore.State, PerKeyDeviceCore.Action, PerKeyDeviceCore.Environment>.combine(
        PerKeySettingsCore.reducer.pullback(
            state: \.settingsState,
            action: /PerKeyDeviceCore.Action.perKeySettings,
            environment: { _ in .init() }
        ),
        PerKeyKeyboardCore.reducer.pullback(
            state: \.keyboardState,
            action: /PerKeyDeviceCore.Action.perKeyKeyboard,
            environment: { _ in .init() }
        ),
        .init { state, action, environment in
            switch action {
            case .onAppear:
                print("Device Core: PerKeyDevice appeared!")
            case .perKeyKeyboard(.onAppear):
                // Set device model to the keyboard to load the correct keyboard layout
                state.keyboardState.model = environment.device.model
            case .refreshSettings:
                // Update Effect settings based on the selected keys
                let selectedKeys = state.keyboardState.keys.filter({ $0.selected }).map({ $0.key })

                if let firstKey = selectedKeys.first {
                    state.settingsState.enabled = true

                    let allSatisfy = selectedKeys.allSatisfy { key in
                        key.effect == firstKey.effect
                    }

                    if allSatisfy {
                        // Set Current
                        let mode = firstKey.effect.mode
                        state.settingsState.mode = mode
                        switch mode {
                        case .steady:
                            state.settingsState.steady = firstKey.effect.main.hsb
                        case .colorShift:
                            let effect = firstKey.effect
                            state.settingsState.speed = CGFloat(effect.duration)
                            state.settingsState.gradientStyle = .gradient
                            state.settingsState.colorSelectors = effect.transitions.compactMap {
                                ColorSelector(
                                    rgb: $0.color,
                                    position: $0.position
                                )
                            }
                            state.settingsState.waveActive = effect.waveActive
                            state.settingsState.direction = effect.direction
                            state.settingsState.control = effect.control
                            state.settingsState.pulse = CGFloat(effect.pulse)
                            state.settingsState.origin = effect.origin
                        case .breathing:
                            let effect = firstKey.effect
                            state.settingsState.speed = CGFloat(effect.duration)
                            state.settingsState.gradientStyle = .breathing
                            state.settingsState.colorSelectors = effect.transitions
                                .enumerated()
                                .filter { $0.offset % 2 == 0 }
                                .compactMap { $0.element }
                                .compactMap { ColorSelector(rgb: $0.color, position: $0.position) }
                        case .reactive:
                            state.settingsState.speed = CGFloat(firstKey.effect.duration)
                            state.settingsState.active = firstKey.effect.active.hsb
                            state.settingsState.rest = firstKey.effect.main.hsb
                        default:
                            break
                        }
                    } else {
                        // Set state to mixed.
                        state.settingsState.mode = .mixed
                    }
                } else {
                    // Set ttate to disabled.
                    state.settingsState.enabled = false
                    state.settingsState.mode = .steady
                }
            case .perKeyKeyboard(.key(id: let identifier, action: .toggleSelection)):
                // If a key selection is changed, check and see what the mouse mode is and either select all keys or not.
                if state.mouseMode == .same, let mainKeyState = state.keyboardState.keys[id: identifier] {
                    for tempKeyState in state.keyboardState.keys {
                        let sameEffect = mainKeyState.key.effect == tempKeyState.key.effect
                        if mainKeyState.selected {
                            state.keyboardState.keys[id: tempKeyState.id]?.selected = sameEffect
                        } else {
                            if sameEffect {
                                state.keyboardState.keys[id: tempKeyState.id]?.selected = false
                            }
                        }
                    }
                }
                return .init(value: .refreshSettings)
            case .perKeyKeyboard(_):
                break
            case .perKeySettings(.modeUpdated(let event)):
                switch event {
                case let .steady(color: color):
                    let steady = color.rgb
                    for id in state.keyboardState.keys.filter({ $0.selected }).ids {
                        state.keyboardState.keys[id: id]?.key.effect.mode = .steady
                        state.keyboardState.keys[id: id]?.key.effect.main = steady
                    }
                case let .colorShift(
                    colorSelectors: colorSelectors,
                    speed: speed,
                    waveActive: active,
                    direction: direction,
                    control: control,
                    pulse: pulse,
                    origin: origin
                ):
                    let transitions = colorSelectors.compactMap {
                        Key.Effect.Transition(
                            color: $0.rgb,
                            position: $0.position
                        )
                    }
                    .sorted(by: { $0.position < $1.position })

                    // This makes sure there are transitions
                    guard transitions.count > 0 else { return .none }

                    var effect = Key.Effect()
                    effect.mode = .colorShift
                    effect.transitions = transitions
                    effect.duration = UInt16(speed)
                    effect.waveActive = active
                    effect.direction = direction
                    effect.control = control
                    effect.origin = origin
                    effect.pulse = UInt16(pulse)

                    for id in state.keyboardState.keys.filter({ $0.selected }).ids {
                        state.keyboardState.keys[id: id]?.key.effect = effect
                    }
                case let .breathing(colorSelectors: colorSelectors, speed: speed):
                    let transitions = colorSelectors.compactMap {
                        Key.Effect.Transition(
                            color: $0.rgb,
                            position: $0.position
                        )
                    }
                    .sorted(by: { $0.position < $1.position })

                    guard transitions.count > 0 else { return .none }

                    var effect = Key.Effect()
                    effect.mode = .breathing
                    effect.transitions = transitions
                    effect.duration = UInt16(speed)

                    for id in state.keyboardState.keys.filter({ $0.selected }).ids {
                        state.keyboardState.keys[id: id]?.key.effect = effect
                    }
                case let .reactive(active: active, rest: rest, speed: speed):
                    let rest = rest.rgb
                    let active = active.rgb
                    let speed = UInt16(speed)

                    for id in state.keyboardState.keys.filter({ $0.selected }).ids {
                        state.keyboardState.keys[id: id]?.key.effect.mode = .reactive
                        state.keyboardState.keys[id: id]?.key.effect.main = rest
                        state.keyboardState.keys[id: id]?.key.effect.active = active
                        state.keyboardState.keys[id: id]?.key.effect.duration = speed
                    }
                case .disabled:
                    for id in state.keyboardState.keys.filter({ $0.selected }).ids {
                        state.keyboardState.keys[id: id]?.key.effect.mode = .disabled
                    }
                }
                
            case .perKeySettings(_):
                break
            case .binding(_):
                break
            case .touchedOutside:
                for id in state.keyboardState.keys.ids {
                    state.keyboardState.keys[id: id]?.selected = false
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
