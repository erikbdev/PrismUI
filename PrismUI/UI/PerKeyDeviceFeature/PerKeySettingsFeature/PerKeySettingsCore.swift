//
//  PerKeySettingsCore.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/21/22.
//

import ComposableArchitecture
import PrismClient

struct PerKeySettingsCore {

    struct State: Equatable {
        var enabled = false

        @BindableState var mode = Key.Effect.Mode.steady

        // MARK: Common Modes

        @BindableState var speed: CGFloat = 3000
        var speedRange: ClosedRange<CGFloat> = 1000...30000

        // MARK: Steady Mode

        @BindableState var steady = HSB(hue: 0, saturation: 1, brightness: 1)

        // MARK: Common Color Shift and Breathing Mode

        @BindableState var gradientStyle = MultiColorSlider.BackgroundStyle.gradient
        @BindableState var colorSelectors = [
            ColorSelector(
                rgb: .init(
                    red: 1.0,
                    green: 1.0,
                    blue: 1.0
                ),
                position: 0
            ),
            ColorSelector(
                rgb: .init(
                    red: 1.0,
                    green: 0.0,
                    blue: 0.0),
                position: 0
            )
        ]

        // MARK: ColorShift Input Properties

        @BindableState var waveActive = false
        @BindableState var direction = Key.Effect.Direction.xy
        @BindableState var control = Key.Effect.Control.inward
        @BindableState var pulse: CGFloat = 100
        @BindableState var origin = Key.Effect.Point()

        // MARK: Reactive Input Properties

        @BindableState var active = HSB(hue: 0, saturation: 1.0, brightness: 1.0)
        @BindableState var rest = HSB()
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<PerKeySettingsCore.State>)
        case updateMode                                         // Check and see if there are any mode update
        case modeUpdated(PerKeySettingsCore.ModeEvent)          // Notify when mode settings has changed
    }

    struct Environment {}

    static let reducer = Reducer<PerKeySettingsCore.State, PerKeySettingsCore.Action, PerKeySettingsCore.Environment> { state, action, environment in
        switch action {
        case .binding(\.$mode):
            switch state.mode {
            case .steady:
                state.steady = .init(hue: 0, saturation: 1, brightness: 1)
            case .colorShift:
                state.gradientStyle = .gradient
                state.colorSelectors = [
                    ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.88), position: 0),
                    ColorSelector(rgb: .init(red: 1.0, green: 0xea/0xff, blue: 0.0), position: 0.32),
                    ColorSelector(rgb: .init(red: 0.0, green: 0xcc/0xff, blue: 1.0), position: 0.76)
                ]
                state.speedRange = 1000...30000
                state.speed = 3000
                state.waveActive = false
                state.control = .inward
                state.direction = .xy
                state.pulse = 100
            case .breathing:
                state.gradientStyle = .breathing
                state.speedRange = 1000...30000
                state.speed = 4000
                state.colorSelectors = [
                    ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.0), position: 0)
                ]
            case .reactive:
                state.speedRange = 100...1000
                state.speed = 300
                state.rest = HSB(hue: 0, saturation: 0, brightness: 0)
                state.active = HSB(hue: 0, saturation: 1.0, brightness: 1.0)
                return .init(value: .updateMode)
            default:
                break
            }
            return .init(value: .updateMode)
        case .binding:
            return .init(value: .updateMode)
        case .updateMode:
            switch state.mode {
            case .steady:
                return .init(
                    value: .modeUpdated(
                        .steady(
                            color: state.steady
                        )
                    )
                )
            case .colorShift:
                return .init(
                    value: .modeUpdated(
                        .colorShift(
                            colorSelectors: state.colorSelectors,
                            speed: state.speed,
                            waveActive: state.waveActive,
                            direction: state.direction,
                            control: state.control,
                            pulse: state.pulse,
                            origin: state.origin
                        )
                    )
                )
            case .breathing:
                return .init(
                    value: .modeUpdated(
                        .breathing(
                            colorSelectors: state.colorSelectors,
                            speed: state.speed
                        )
                    )
                )
            case .reactive:
                return .init(
                    value: .modeUpdated(
                        .reactive(
                            active: state.active,
                            rest: state.rest,
                            speed: state.speed
                        )
                    )
                )
            case .disabled:
                return .init(
                    value: .modeUpdated(
                        .disabled
                    )
                )
            default:
                break
            }
        default:
            break
        }
        return .none
    }
    .binding()

    enum ModeEvent: Equatable {
        case steady(color: HSB)
        case colorShift(colorSelectors: [ColorSelector], speed: CGFloat, waveActive: Bool, direction: Key.Effect.Direction, control: Key.Effect.Control, pulse: CGFloat, origin: Key.Effect.Point)
        case breathing(colorSelectors: [ColorSelector], speed: CGFloat)
        case reactive(active: HSB, rest: HSB, speed: CGFloat)
        case disabled
    }
}
