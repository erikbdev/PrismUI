//
//  KeySettingsViewModel.swift
//  PrismUI
//
//  Created by Erik Bautista on 12/20/21.
//

import Combine
import PrismClient
import OrderedCollections
import Ricemill

final class KeySettingsViewModel: Machine<KeySettingsViewModel> {
    typealias Output = Store

    // MARK: - User Input Bindings

    final class Input: BindableInputType {
        let selectedKeys = PassthroughSubject<[Key], Never>()

        @Published var selectedMode: Key.Modes = .steady

        // MARK: Common Input
        @Published var speed: CGFloat = 3000 // Speed Settings

        // MARK: Steady Input Config
        @Published var steady = HSB(hue: 0, saturation: 1, brightness: 1)

        // MARK: Common Colorshift and Breathing Input Properties
        @Published var gradientStyle: MultiColorSlider.BackgroundStyle = .gradient
        @Published var colorSelectors = [ColorSelector(rgb: .init(red: 1.0, green: 1.0, blue: 1.0), position: 0),
                                         ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.0), position: 0)]

        // MARK: ColorShift Input Properties
        @Published var waveActive = false
        @Published var direction: KeyEffect.Direction = .xy
        @Published var control: KeyEffect.Control = .inward
        @Published var pulse: CGFloat = 100
        @Published var origin: KeyEffect.PerKeyPoint = KeyEffect.PerKeyPoint()

        // MARK: Reactive Input Properties
        @Published var active = HSB(hue: 0, saturation: 1.0, brightness: 1.0)
        @Published var rest = HSB()
    }

    // MARK: - Output data

    final class Store: StoredOutputType {
        @Published var selectedMode: Key.Modes = .steady

        // MARK: Common Oyroyt
        @Published var speed: CGFloat = 3000 // Speed Settings

        // MARK: Steady Output Properties
        @Published var steady = HSB(hue: 0, saturation: 1, brightness: 1)

        // MARK: Common Colorshift and Breathing Output Properties
        @Published var gradientStyle: MultiColorSlider.BackgroundStyle = .gradient
        @Published var colorSelectors = [ColorSelector(rgb: .init(red: 1.0, green: 1.0, blue: 1.0), position: 0),
                                         ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.0), position: 0)]

        // MARK: ColorShift Output Properties
        @Published var waveActive = false
        @Published var direction: KeyEffect.Direction = .xy
        @Published var control: KeyEffect.Control = .inward
        @Published var pulse: CGFloat = 100
        @Published var origin: KeyEffect.PerKeyPoint = KeyEffect.PerKeyPoint()

        // MARK: Reactive Output  Properties
        @Published var active = HSB(hue: 0, saturation: 1.0, brightness: 1.0)
        @Published var rest = HSB()

        var speedRange: ClosedRange<CGFloat> = 1000...30000
        fileprivate var ignoreInput = false
    }

    struct Extra: ExtraType {
        var updateCallback: ((KeyEffectEvent) -> Void)? = nil
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

        input.$steady
            .assign(to: \.steady, on: store)
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

        input.$direction
            .assign(to: \.direction, on: store)
            .store(in: &cancellables)

        input.$control
            .assign(to: \.control, on: store)
            .store(in: &cancellables)

        input.$pulse
            .assign(to: \.pulse, on: store)
            .store(in: &cancellables)

        input.$origin
            .assign(to: \.origin, on: store)
            .store(in: &cancellables)

        input.$active
            .assign(to: \.active, on: store)
            .store(in: &cancellables)

        input.$rest
            .assign(to: \.rest, on: store)
            .store(in: &cancellables)

        let selectedMode = input.$selectedMode
            .filter { $0 != .mixed }
            .share()

        // MARK: - Set default values for when a user input mode changed

        // MARK: Steady Default Value
        selectedMode
            .filter { $0 == .steady }
            .map { _ in () }
            .dropFirst()
            .sink {
                store.ignoreInput = true
                store.selectedMode = .steady
                store.steady = .init(hue: 0, saturation: 1.0, brightness: 1.0)
                store.ignoreInput = false

                extra.updateCallback?(.steady(color: store.steady))
            }
            .store(in: &cancellables)

        // MARK: Color Shift Default Values
        selectedMode
            .filter { $0 == .colorShift }
            .map { _ in () }
            .sink {
                store.ignoreInput = true
                store.selectedMode = .colorShift
                store.gradientStyle = .gradient
                store.colorSelectors = [
                    ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.88), position: 0),
                    ColorSelector(rgb: .init(red: 1.0, green: 0xea/0xff, blue: 0.0), position: 0.32),
                    ColorSelector(rgb: .init(red: 0.0, green: 0xcc/0xff, blue: 1.0), position: 0.76)
                ]
                store.speedRange = 1000...30000
                store.speed = 3000
                store.waveActive = false
                store.control = .inward
                store.direction = .xy
                store.pulse = 100
                store.origin = .init()
                store.ignoreInput = false

                extra.updateCallback?(.colorShift(colorSelectors: store.colorSelectors,
                                                  speed: store.speed,
                                                  waveActive: store.waveActive,
                                                  waveDirection: store.direction,
                                                  waveControl: store.control,
                                                  pulse: store.pulse,
                                                  origin: store.origin)
                )
            }
            .store(in: &cancellables)

        // MARK: Breathing Default Values
        selectedMode
            .filter { $0 == .breathing }
            .map { _ in () }
            .sink {
                store.ignoreInput = true
                store.selectedMode = .breathing
                store.gradientStyle = .breathing
                store.speedRange = 1000...30000
                store.speed = 4000
                store.colorSelectors = [
                    ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.0), position: 0)
                ]
                store.ignoreInput = false

                extra.updateCallback?(.breathing(colorSelectors: store.colorSelectors, speed: store.speed))
            }
            .store(in: &cancellables)

        // MARK: Reactive Default Values
        selectedMode
            .filter { $0 == .reactive }
            .map { _ in () }
            .sink {
                store.ignoreInput = true
                store.selectedMode = .reactive
                store.active = .init(hue: 0, saturation: 1.0, brightness: 1.0)
                store.rest = .init()
                store.speedRange = 100...1000
                store.speed = 300
                store.ignoreInput = false

                extra.updateCallback?(.reactive(activeColor: store.active, restColor: store.rest, speed: store.speed))
            }
            .store(in: &cancellables)

        // MARK: Disabled Default Values
        selectedMode
            .filter { $0 == .disabled }
            .map { _ in () }
            .sink {
                store.ignoreInput = true
                store.selectedMode = .disabled
                store.ignoreInput = false

                extra.updateCallback?(.disabled)
            }
            .store(in: &cancellables)

        // MARK: - Handle any input value changes

        store.$steady
            .filter { _ in store.selectedMode == .steady }
            .filter { _ in !store.ignoreInput }
            .dropFirst()
            .sink { color in
                extra.updateCallback?(.steady(color: color))
            }
            .store(in: &cancellables)

        store.$colorSelectors
            .combineLatest(store.$speed, store.$waveActive, store.$direction, store.$control, store.$pulse, store.$origin)
            .filter { _ in store.selectedMode == .colorShift }
            .filter { _ in !store.ignoreInput }
            .sink { (colorSelectors, speed, wave, direction, control, pulse, origin) in
                extra.updateCallback?(.colorShift(
                        colorSelectors: colorSelectors,
                        speed: speed,
                        waveActive: wave,
                        waveDirection: direction,
                        waveControl: control,
                        pulse: pulse,
                        origin: origin
                    )
                )
            }
            .store(in: &cancellables)

        store.$colorSelectors
            .combineLatest(store.$speed)
            .filter { _ in store.selectedMode == .breathing }
            .filter { _ in !store.ignoreInput }
            .sink { (colorSelectors, speed) in
                extra.updateCallback?(.breathing(colorSelectors: colorSelectors, speed: speed))
            }
            .store(in: &cancellables)

        store.$active
            .combineLatest(store.$rest, store.$speed)
            .filter { _ in store.selectedMode == .reactive }
            .filter { _ in !store.ignoreInput }
            .sink { (activeColor, restColor, speed) in
                extra.updateCallback?(.reactive(activeColor: activeColor, restColor: restColor, speed: speed))
            }
            .store(in: &cancellables)

        input.selectedKeys
            .removeDuplicates()
            .sink { selectedKeys in
                store.ignoreInput = true
                if let firstKey = selectedKeys.first {
                    let allSatisfy = selectedKeys.allSatisfy { $0.sameEffect(as: firstKey) }

                    if allSatisfy {
                        let mode = firstKey.mode

                        store.selectedMode = mode

                        switch mode {
                        case .steady:
                            store.steady = firstKey.main.hsb
                        case .colorShift:
                            if let effect = firstKey.effect {
                                store.colorSelectors = effect.transitions
                                    .compactMap({ ColorSelector(rgb: $0.color, position: $0.position) })
                                store.speed = CGFloat(effect.duration)
                                store.waveActive = effect.waveActive
                                store.direction = effect.direction
                                store.control = effect.control
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
                            store.active = firstKey.active.hsb
                            store.rest = firstKey.main.hsb
                            store.speed = CGFloat(firstKey.duration)
                        default:
                            break
                        }
                    } else {
                        store.selectedMode = .mixed
                    }
                }
                store.ignoreInput = false
            }
            .store(in: &cancellables)

        return .init(cancellables: cancellables)
    }

    static func make(extra: Extra) -> KeySettingsViewModel {
        return KeySettingsViewModel(input: Input(), store: Store(), extra: extra)
    }
}
