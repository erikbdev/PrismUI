//
//  KeySettingsViewModel.swift
//  PrismUI
//
//  Created by Erik Bautista on 12/20/21.
//

import Combine
import PrismKit
import OrderedCollections
import Ricemill

final class KeySettingsViewModel: Machine<KeySettingsViewModel> {
    typealias Output = Store

    // MARK: - User Input Bindings

    final class Input: BindableInputType {
        let appearedTrigger = PassthroughSubject<Void, Never>()

        @Published var selectedMode: SSKey.SSKeyModes = .steady

        // MARK: Common Input
        @Published var speed: CGFloat = 3000 // Speed Settings

        // MARK: Steady Input Config
        @Published var steadyColor = HSB(hue: 0, saturation: 1, brightness: 1)

        // MARK: Common Colorshift and Breathing Input Properties
        @Published var gradientStyle: MultiColorSliderBackgroundStyle = .gradient
        @Published var colorSelectors = [ColorSelector(rgb: .init(red: 1.0, green: 1.0, blue: 1.0), position: 0),
                                         ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.0), position: 0)]

        // MARK: ColorShift Input Properties
        @Published var waveActive = false
        @Published var waveDirection: SSKeyEffect.SSPerKeyDirection = .xy
        @Published var waveControl: SSKeyEffect.SSPerKeyControl = .inward
        @Published var pulse: CGFloat = 100
        @Published var origin: SSKeyEffect.SSPoint = SSKeyEffect.SSPoint()

        // MARK: Reactive Input Properties
        @Published var activeColor = HSB(hue: 0, saturation: 1.0, brightness: 1.0)
        @Published var restColor = HSB()
    }

    // MARK: - Output data

    final class Store: StoredOutputType {
        @Published var selectedMode: SSKey.SSKeyModes = .steady

        // MARK: Common Oyroyt
        @Published var speed: CGFloat = 3000 // Speed Settings

        // MARK: Steady Output Properties
        @Published var steadyColor = HSB(hue: 0, saturation: 1, brightness: 1)

        // MARK: Common Colorshift and Breathing Output Properties
        @Published var gradientStyle: MultiColorSliderBackgroundStyle = .gradient
        @Published var colorSelectors = [ColorSelector(rgb: .init(red: 1.0, green: 1.0, blue: 1.0), position: 0),
                                         ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.0), position: 0)]

        // MARK: ColorShift Output Properties
        @Published var waveActive = false
        @Published var waveDirection: SSKeyEffect.SSPerKeyDirection = .xy
        @Published var waveControl: SSKeyEffect.SSPerKeyControl = .inward
        @Published var pulse: CGFloat = 100
        @Published var origin: SSKeyEffect.SSPoint = SSKeyEffect.SSPoint()

        // MARK: Reactive Output  Properties
        @Published var activeColor = HSB(hue: 0, saturation: 1.0, brightness: 1.0)
        @Published var restColor = HSB()

        var speedRange: ClosedRange<CGFloat> = 1000...30000
    }

    struct Extra: ExtraType {
        var selectedKeys: [SSKey]
    }

    static func polish(input: Publishing<Input>, store: Store, extra: Extra) -> Polished<Output> {
        var cancellables: [AnyCancellable] = []

        // Input Binding to Output

        input.$selectedMode
            .assign(to: \.selectedMode, on: store)
            .store(in: &cancellables)

        input.$speed
            .assign(to: \.speed, on: store)
            .store(in: &cancellables)

        input.$steadyColor
            .assign(to: \.steadyColor, on: store)
            .store(in: &cancellables)

        input.$gradientStyle
            .assign(to: \.gradientStyle, on: store)
            .store(in: &cancellables)

        input.$colorSelectors
            .assign(to: \.colorSelectors, on: store)
            .store(in: &cancellables)

        input.$waveActive
            .assign(to: \.waveActive, on: store)
            .store(in: &cancellables)

        input.$waveDirection
            .assign(to: \.waveDirection, on: store)
            .store(in: &cancellables)

        input.$waveControl
            .assign(to: \.waveControl, on: store)
            .store(in: &cancellables)

        input.$pulse
            .assign(to: \.pulse, on: store)
            .store(in: &cancellables)

        input.$origin
            .assign(to: \.origin, on: store)
            .store(in: &cancellables)

        input.$activeColor
            .assign(to: \.activeColor, on: store)
            .store(in: &cancellables)

        input.$restColor
            .assign(to: \.restColor, on: store)
            .store(in: &cancellables)

        let selectedMode = store.$selectedMode
            .share()

        // MARK: - Set default values for a given mode on change

        // MARK: Steady Default Value
        selectedMode
            .filter { $0 == .steady }
            .map { _ in () }
            .sink {
                store.steadyColor = .init(hue: 0, saturation: 1.0, brightness: 1.0)
            }
            .store(in: &cancellables)

        // MARK: Color Shift Default Values
        selectedMode
            .filter { $0 == .colorShift }
            .map { _ in () }
            .sink {
                store.gradientStyle = .gradient
                store.colorSelectors = [
                    ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.88), position: 0),
                    ColorSelector(rgb: .init(red: 1.0, green: 0xea/0xff, blue: 0.0), position: 0.32),
                    ColorSelector(rgb: .init(red: 0.0, green: 0xcc/0xff, blue: 1.0), position: 0.76)
                ]
                store.speedRange = 1000...30000
                store.speed = 3000
                store.waveActive = false
                store.waveControl = .inward
                store.waveDirection = .xy
                store.pulse = 100
            }
            .store(in: &cancellables)

        // MARK: Breathing Default Values
        selectedMode
            .filter { $0 == .breathing }
            .map { _ in () }
            .sink {
                store.gradientStyle = .breathing
                store.speedRange = 1000...30000
                store.speed = 4000
                store.colorSelectors = [
                    ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.0), position: 0)
                ]
            }
            .store(in: &cancellables)

        // MARK: Reactive Default Values
        selectedMode
            .filter { $0 == .reactive }
            .map { _ in () }
            .sink {
                store.activeColor = .init(hue: 0, saturation: 1.0, brightness: 1.0)
                store.restColor = .init()
            }
            .store(in: &cancellables)

        // MARK: Disabled Default Values
        selectedMode
            .filter { $0 == .disabled }
            .map { _ in () }
            .sink {
            }
            .store(in: &cancellables)

        // MARK: - Handle any input value changes

        input.$steadyColor
            .filter { _ in input.selectedMode == .steady }
//            .dropFirst()
            .sink { color in
                print("Steady")
            }
            .store(in: &cancellables)

        input.$colorSelectors
            .combineLatest(input.$speed, input.$waveActive, input.$waveDirection, input.$waveControl, input.$pulse, input.$origin)
            .filter { _ in input.selectedMode == .colorShift }
//            .dropFirst()
            .sink { (colorSelectors, speed, wave, waveDirection, waveControl, pulse, origin) in
                print("Color Shift")
            }
            .store(in: &cancellables)

        input.$colorSelectors
            .combineLatest(input.$speed)
            .filter { _ in input.selectedMode == .breathing }
//            .dropFirst()
            .sink { (colorSelectors, speed) in
                print("Breathing")
            }
            .store(in: &cancellables)

        input.$activeColor
            .combineLatest(input.$restColor, input.$speed)
            .filter { _ in input.selectedMode == .reactive }
//            .dropFirst()
            .sink { (activeColor, restColor, speed) in
                print("Reactive")
            }
            .store(in: &cancellables)

        return .init(cancellables: cancellables)
    }

    static func make(extra: Extra) -> KeySettingsViewModel {
        let store = Store()

        // Set state of view before creating the view model

        if let firstKey = extra.selectedKeys.first {
            let allSatisfy = extra.selectedKeys.allSatisfy { $0.sameEffect(as: firstKey) }

            if allSatisfy {
                let mode = firstKey.mode

                store.selectedMode = mode

                switch mode {
                case .steady:
                    store.steadyColor = firstKey.main.hsb
                case .colorShift:
                    if let effect = firstKey.effect {
                        store.colorSelectors = effect.transitions
                            .compactMap({ ColorSelector(rgb: $0.color, position: $0.position) })
                        store.speed = CGFloat(effect.duration)
                        store.waveActive = effect.waveActive
                        store.waveDirection = effect.direction
                        store.waveControl = effect.control
                        store.origin = effect.origin
                        store.pulse = CGFloat(effect.pulse)
                    }
                case .breathing:
                    if let effect = firstKey.effect {
                        store.colorSelectors = effect.transitions
                            .enumerated()
                            .filter({ $0.offset % 2 == 0 })
                            .compactMap({ $0.element })
                            .compactMap({ ColorSelector(rgb: $0.color, position: $0.position) })
                        store.speed = CGFloat(effect.duration)
                    }
                case .reactive:
                    store.activeColor = firstKey.active.hsb
                    store.restColor = firstKey.main.hsb
                    store.speed = CGFloat(firstKey.duration)
                default:
                    break
                }
            } else {
                store.selectedMode = .mixed
            }
        }

        return KeySettingsViewModel(input: Input(), store: store, extra: extra)
    }
}
