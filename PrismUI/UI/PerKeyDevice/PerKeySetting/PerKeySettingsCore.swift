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
        @BindableState var mode = Key.Modes.steady

        // MARK: Common Modes

        @BindableState var speed: CGFloat = 3000
        private(set) var speedRange: ClosedRange<CGFloat> = 1000...30000

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
    }

    struct Environment {}

    static let reducer = Reducer<PerKeySettingsCore.State, PerKeySettingsCore.Action, PerKeySettingsCore.Environment> { state, action, environment in
        switch action {
        case .binding(\.$mode):
            print("Mode changed")
            break
        case .binding:
            break
        }
        return .none
    }
    .binding()
}
