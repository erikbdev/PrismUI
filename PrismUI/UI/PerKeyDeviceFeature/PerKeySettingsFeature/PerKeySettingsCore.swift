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

        @BindableState var mode = Key.Modes.steady

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
        @BindableState var direction = KeyEffect.Direction.xy
        @BindableState var control = KeyEffect.Control.inward
        @BindableState var pulse: CGFloat = 100
        @BindableState var origin: KeyEffect.PerKeyPoint = KeyEffect.PerKeyPoint()

        // MARK: Reactive Input Properties

        @BindableState var active = HSB(hue: 0, saturation: 1.0, brightness: 1.0)
        @BindableState var rest = HSB()
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<PerKeySettingsCore.State>)
        case updatedValues(touchUp: Bool)
    }

    struct Environment {}

    static let reducer = Reducer<PerKeySettingsCore.State, PerKeySettingsCore.Action, PerKeySettingsCore.Environment> { state, action, environment in
        switch action {
        case .binding(\.$mode):
            switch state.mode {
            case .steady:
                state.steady = .init(hue: 0, saturation: 1, brightness: 1)
                return .init(value: .updatedValues(touchUp: true))
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
                return .init(value: .updatedValues(touchUp: true))
            case .breathing:
                state.gradientStyle = .breathing
                state.speedRange = 1000...30000
                state.speed = 4000
                state.colorSelectors = [
                    ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.0), position: 0)
                ]
                return .init(value: .updatedValues(touchUp: true))
            case .reactive:
                state.speedRange = 100...1000
                state.speed = 300
                state.rest = HSB(hue: 0, saturation: 0, brightness: 0)
                state.active = HSB(hue: 0, saturation: 1.0, brightness: 1.0)
                return .init(value: .updatedValues(touchUp: true))
            case .disabled:
                return .init(value: .updatedValues(touchUp: true))
            default:
                break
            }
        case .binding(\.$steady):
            return .init(value: .updatedValues(touchUp: true))

        case .binding:
            break
        case .updatedValues(_):
            break
        }
        return .none
    }
    .binding()
}
