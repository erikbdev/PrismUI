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

    final class Input: BindableInputType {
        let appearedTrigger = PassthroughSubject<Void, Never>()
        let showOriginTrigger = PassthroughSubject<Void, Never>()

        @Published var selectedMode: SSKey.SSKeyModes = .steady

        // MARK: - Common
        @Published var speed: CGFloat = 3000 // Speed Settings

        // MARK: - Steady Config
        @Published var steadyColor = HSB(hue: 0, saturation: 1, brightness: 1)

        // MARK: - Common Colorshift and Breathing Properties
        @Published var gradientSliderMode: MultiColorSliderBackgroundStyle = .gradient
        @Published var colorSelectors = [ColorSelector(rgb: .init(red: 1.0, green: 1.0, blue: 1.0), position: 0),
                                         ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.0), position: 0)]

        // MARK: - ColorShift Properties
        @Published var waveActive = false
        @Published var waveDirection: SSKeyEffect.SSPerKeyDirection = .xy
        @Published var waveControl: SSKeyEffect.SSPerKeyControl = .inward
        @Published var pulse: CGFloat = 100
        // TODO: Add origin for colorShift
        @Published var origin: SSKeyEffect.SSPoint = SSKeyEffect.SSPoint()

        // MARK: - Reactive Properties
        @Published var activeColor = HSB(hue: 0, saturation: 1.0, brightness: 1.0)
        @Published var restColor = HSB()
    }

    final class Store: StoredOutputType {
        @Published var selectedMode: SSKey.SSKeyModes = .steady

        @Published var speedRange: ClosedRange<CGFloat> = 1000...30000
        @Published var waveActive = false
    }

    struct Extra: ExtraType {}

    static func polish(input: Publishing<Input>, store: Store, extra: Extra) -> Polished<Output> {
        var cancellables: [AnyCancellable] = []

        input.$selectedMode
            .assign(to: \.selectedMode, on: store)
            .store(in: &cancellables)

        input.$waveActive
            .assign(to: \.waveActive, on: store)
            .store(in: &cancellables)

        return .init(cancellables: cancellables)
    }

    static func make(extra: Extra) -> KeySettingsViewModel {
        KeySettingsViewModel(input: Input(), store: Store(), extra: extra)
    }
//    static func
}

//final class KeySettingsViewModel: BaseViewModel, UniDirectionalDataFlowType {
//    enum Input {
//        case onAppear
//        case onShowOrigin
//    }
//
//    func apply(_ input: Input) {
//        switch input {
//        case .onAppear:
//            onAppearSubject.send()
//        case .onShowOrigin:
//            onShowOriginSubject.send()
//        }
//    }
//
//    // MARK: - Subjects
//
//    private let onAppearSubject = PassthroughSubject<Void, Never>()
//    private let onShowOriginSubject = PassthroughSubject<Void, Never>()
//
//    // MARK: - Main Data
//
//    var selectedKeyModels: Set<KeyViewModel> {
//        didSet {
//            // TODO: Notify when size of selected key changed
//            handleSelectedKeyModelsArrayChanged(oldSelection: oldValue)
//        }
//    }
//
//    private var skipDefaultValues = false
//
//    // If `selectedKeyModels` array is changed, we want to copy the value from the model to our view, but
//    // we do not want our view inputs to change our model while this is happening.
//    private var settingModeToView = false
//
//    // If mode is changed, it will reset all values but we do not want to
//    // get notified until the last value is reset so we can update the model
//    private var modeChanging = false
//
//    // MARK: - Effects
//
//    @Published var selectedMode: SSKey.SSKeyModes = .steady
//
//    // MARK: Steady Effect
//
//    @Published var steadyColor = HSB(hue: 0, saturation: 1, brightness: 1)
//
//    // MARK: Common Effect Settings
//
//    @Published var speed: CGFloat = 3000 // Speed Settings
//    @Published var speedRange: ClosedRange<CGFloat> = 1000...30000
//
//    // MARK: Common Color Shift and Breathing
//
//    @Published var gradientSliderMode: MultiColorSliderBackgroundStyle = .gradient
//    @Published var colorSelectors = [ColorSelector(rgb: .init(red: 1.0, green: 1.0, blue: 1.0), position: 0),
//                                ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.0), position: 0)] // Just for testing, shouldn't be shown
//
//    // MARK: Color Shift Settings
//
//    @Published var waveActive = false
//    @Published var waveDirection: SSKeyEffect.SSPerKeyDirection = .xy
//    @Published var waveControl: SSKeyEffect.SSPerKeyControl = .inward
//    @Published var pulse: CGFloat = 100
//    @Published var origin: SSKeyEffect.SSPoint = SSKeyEffect.SSPoint() // TODO: Add origin for colorShift
//
//    // MARK: Reactive Settings
//
//    @Published var activeColor = HSB(hue: 0, saturation: 1.0, brightness: 1.0)
//    @Published var restColor = HSB()
//
//    var updateDevice: () -> ()
//
//    init(keyModels: Set<KeyViewModel>, updateDevice: @escaping () -> ()) {
//        self.selectedKeyModels = keyModels
//        self.updateDevice = updateDevice
//        super.init()
//
//        bind()
//    }
//
//    private func bind() {
//        onAppearSubject
//            .sink { _ in
//                
//            }
//            .store(in: &cancellables)
//
//        onShowOriginSubject
//            .sink { _ in
//                
//            }
//            .store(in: &cancellables)
//
//        // Observe selectedMode and change view state on main thread.
//        $selectedMode
//            .receive(on: RunLoop.main)
//            .sink { [weak self] newMode in
//                self?.handleModeChanged(newMode: newMode)
//            }
//            .store(in: &cancellables)
//
//        // Steady Mode
//        $steadyColor
//            .filter({ [weak self] _ in
//                self?.selectedMode == .steady &&
//                self?.modeChanging == false &&
//                self?.settingModeToView == false &&
//                self?.selectedKeyModels.count ?? 0 > 0
//            })
//            .sink { [weak self] newColor in
////                print("Update Steady")
//                self?.handleSteadyMode(newColor: newColor)
//                self?.updateDevice()
//            }
//            .store(in: &cancellables)
//
//        // Color Shift Mode
//
//        $colorSelectors
//            .combineLatest($speed, $waveActive, $waveDirection, $waveControl, $pulse, $origin)
//            .filter({ [weak self] _ in
//                self?.selectedMode == .colorShift &&
//                self?.modeChanging == false &&
//                self?.settingModeToView == false &&
//                self?.selectedKeyModels.count ?? 0 > 0
//            })
//            .sink { [weak self] (newColorSelectors,
//                                 newSpeed,
//                                 newWave,
//                                 newWaveDirection,
//                                 newWaveControl,
//                                 newPulse,
//                                 newOrigin) in
////                print("Update Color Shift")
//                self?.handleColorShift(newSelectors: newColorSelectors,
//                                       newSpeed: newSpeed,
//                                       newWave: newWave,
//                                       newWaveDirection: newWaveDirection,
//                                       newWaveControl: newWaveControl,
//                                       newOrigin: newOrigin,
//                                       newPulse: newPulse)
//                self?.updateDevice()
//            }
//            .store(in: &cancellables)
//
//        // Breathing Mode
//
//        $colorSelectors
//            .combineLatest($speed)
//            .filter({ [weak self] _ in
//                self?.selectedMode == .breathing &&
//                self?.modeChanging == false &&
//                self?.settingModeToView == false &&
//                self?.selectedKeyModels.count ?? 0 > 0
//            })
//            .sink { [weak self] (newColorSelectors, newSpeed) in
////                print("Update Breathing")
//                self?.handleBreathing(newSelectors: newColorSelectors, newSpeed: newSpeed)
//                self?.updateDevice()
//            }
//            .store(in: &cancellables)
//
//        // Reactive Mode
//
//        $activeColor
//            .combineLatest($restColor, $speed)
//            .filter({ [weak self] _ in
//                self?.selectedMode == .reactive &&
//                self?.modeChanging == false &&
//                self?.settingModeToView == false &&
//                self?.selectedKeyModels.count ?? 0 > 0
//            })
//            .sink { [weak self] (newActive, newRest, newSpeed) in
////                print("Update Reactive")
//                self?.handleReactive(newActiveColor: newActive.rgb, newRestColor: newRest.rgb, newSpeed: newSpeed)
//                self?.updateDevice()
//            }
//            .store(in: &cancellables)
//
//        // Disabled Mode
//
//        $selectedMode
//            .filter({ [weak self] mode in
//                mode == .disabled &&
//                self?.modeChanging == false &&
//                self?.settingModeToView == false &&
//                self?.selectedKeyModels.count ?? 0 > 0
//            })
//            .sink { [weak self] _ in
////                print("Update Disabled")
//                self?.handleDisabled()
//                self?.updateDevice()
//            }
//            .store(in: &cancellables)
//    }
//
//    private func handleSelectedKeyModelsArrayChanged(oldSelection: Set<KeyViewModel>) {
//        guard oldSelection != selectedKeyModels else { return }
//        handleKeysSelectedChanged(newModels: selectedKeyModels)
//    }
//
//    private func handleKeysSelectedChanged(newModels: Set<KeyViewModel>) {
//        guard let firstKeyModel = newModels.first else {
//            // No selected values, set view to steady default
//            skipDefaultValues = true
//            selectedMode = .steady
//            skipDefaultValues = false
//            return
//        }
//        let allSatisfy = newModels.allSatisfy({ $0.ssKey.sameEffect(as: firstKeyModel.ssKey) })
//
//        skipDefaultValues = true
//
//        // Set main color picker based on mode
//        if allSatisfy, let firstKeyModel = newModels.first {
//            settingModeToView = true
//            let mode = firstKeyModel.ssKey.mode
//
//            selectedMode = mode
//
//            switch mode {
//            case .steady:
//                steadyColor = firstKeyModel.ssKey.main.hsb
//            case .colorShift:
//                if let effect = firstKeyModel.ssKey.effect {
//                    colorSelectors = effect.transitions
//                        .compactMap({ ColorSelector(rgb: $0.color, position: $0.position) })
//                    speed = CGFloat(effect.duration)
//                    waveActive = effect.waveActive
//                    waveDirection = effect.direction
//                    waveControl = effect.control
//                    origin = effect.origin
//                    pulse = CGFloat(effect.pulse)
//                }
//            case .breathing:
//                if let effect = firstKeyModel.ssKey.effect {
//                    colorSelectors = effect.transitions
//                        .enumerated()
//                        .filter({ $0.offset % 2 == 0 })
//                        .compactMap({ $0.element })
//                        .compactMap({ ColorSelector(rgb: $0.color, position: $0.position) })
//                    speed = CGFloat(effect.duration)
//                }
//            case .reactive:
//                activeColor = firstKeyModel.ssKey.active.hsb
//                restColor = firstKeyModel.ssKey.main.hsb
//                speed = CGFloat(firstKeyModel.ssKey.duration)
//            default:
//                break
//            }
//        } else {
//            selectedMode = .mixed
//        }
//        settingModeToView = false
//    }
//
//}
//
//// MARK: - Mode Functions
//
//extension KeySettingsViewModel {
//    private func handleModeChanged(newMode: SSKey.SSKeyModes) {
//        guard !skipDefaultValues else { skipDefaultValues = false; return }
//        modeChanging = true
//
//        switch newMode {
//        case SSKey.SSKeyModes.steady:
//            switchToSteady()
//        case SSKey.SSKeyModes.colorShift:
//            switchToColorShift()
//        case SSKey.SSKeyModes.breathing:
//            switchToBreathing()
//        case SSKey.SSKeyModes.reactive:
//            switchToReactive()
//        default:
//            modeChanging = false
//        }
//    }
//
//    // MARK: - Steady Mode
//
//    private func switchToSteady() {
//        modeChanging = false // This will allow to update keys to this mode
//        steadyColor = HSB(hue: 0, saturation: 1, brightness: 1)
//    }
//
//    private func handleSteadyMode(newColor: HSB) {
//        selectedKeyModels.forEach { keyModel in
//            keyModel.ssKey.mode = .steady
//            keyModel.ssKey.main = newColor.rgb
//        }
//    }
//
//    // MARK: - Color Shift
//
//    private func switchToColorShift() {
//        gradientSliderMode = .gradient
//        colorSelectors = [
//            ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.88), position: 0),
//            ColorSelector(rgb: .init(red: 1.0, green: 0xea/0xff, blue: 0.0), position: 0.32),
//            ColorSelector(rgb: .init(red: 0.0, green: 0xcc/0xff, blue: 1.0), position: 0.76)
//        ]
//        speedRange = 1000...30000
//        speed = 3000
//        waveActive = false
//        waveControl = .inward
//        waveDirection = .xy
//        modeChanging = false // This will allow to update keys to this mode
//        pulse = 100
//    }
//
//    private func handleColorShift(newSelectors: [ColorSelector],
//                                  newSpeed: CGFloat,
//                                  newWave: Bool,
//                                  newWaveDirection: SSKeyEffect.SSPerKeyDirection,
//                                  newWaveControl: SSKeyEffect.SSPerKeyControl,
//                                  newOrigin: SSKeyEffect.SSPoint,
//                                  newPulse: CGFloat) {
//        // TODO: Handle generating id for effect
//        let transitions = newSelectors.compactMap({ SSKeyEffect.SSPerKeyTransition(color: $0.rgb, position: $0.position) })
//            .sorted(by: { $0.position < $1.position })
//
//        guard transitions.count > 0 else { return }
//
//        var effect = SSKeyEffect(id: 0,
//                                 transitions: transitions)
//
//        effect.start = transitions[0].color
//        effect.duration = UInt16(newSpeed)
//        effect.waveActive = newWave
//        effect.direction = newWaveDirection
//        effect.control = newWaveControl
//        effect.origin = newOrigin
//        effect.pulse = UInt16(newPulse)
//
//        selectedKeyModels.forEach { keyModel in
//            keyModel.ssKey.mode = .colorShift
//            keyModel.ssKey.effect = effect
//            keyModel.ssKey.main = effect.start
//        }
//    }
//
//    // MARK: - Breathing
//
//    private func switchToBreathing() {
//        gradientSliderMode = .breathing
//        speedRange = 1000...30000
//        speed = 4000
//        modeChanging = false // This will allow to update keys to this mode
//        colorSelectors = [
//            ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.0), position: 0)
//        ]
//    }
//
//    private func handleBreathing(newSelectors: [ColorSelector], newSpeed: CGFloat) {
//        let baseTransitions = newSelectors.compactMap({ SSKeyEffect.SSPerKeyTransition(color: $0.rgb, position: $0.position) })
//            .sorted(by: { $0.position < $1.position })
//
//        guard baseTransitions.count > 0 else {
//            print("Cannot use latest transition from breathing mode because there are no transitions.")
//            return
//        }
//
//        var transitions: [SSKeyEffect.SSPerKeyTransition] = []
//
//        // We add the transitions from baseTransition and also add the half values between
//        // each transition to have the breathing effect.
//        for inx in baseTransitions.indices {
//            let firstSelector = baseTransitions[inx]
//            transitions.append(firstSelector)
//
//            var halfDistance: CGFloat
//            if (inx + 1) < baseTransitions.count {
//                let secondSelector = baseTransitions[inx + 1]
//                halfDistance = (secondSelector.position + firstSelector.position) / 2
//            } else {
//                halfDistance = (1 + firstSelector.position) / 2
//            }
//
//            transitions.append(SSKeyEffect.SSPerKeyTransition(color: RGB(), position: halfDistance))
//        }
//
//        var effect = SSKeyEffect(id: 0,
//                                 transitions: transitions)
//
//        effect.start = transitions[0].color
//        effect.duration = UInt16(newSpeed)
//
//        selectedKeyModels.forEach { keyModel in
//            keyModel.ssKey.mode = .breathing
//            keyModel.ssKey.effect = effect
//            keyModel.ssKey.main = effect.start
//        }
//    }
//
//    // MARK: - Reactive
//
//    private func switchToReactive() {
//        // These value changes will notify our listeners
//        speedRange = 100...1000
//        speed = 300
//        restColor = HSB(hue: 0, saturation: 0, brightness: 0)
//        modeChanging = false // This will allow to update keys to this mode
//        activeColor = HSB(hue: 0, saturation: 1.0, brightness: 1.0)
//    }
//
//    private func handleReactive(newActiveColor: RGB, newRestColor: RGB, newSpeed: CGFloat) {
//        selectedKeyModels.forEach { keyVM in
//            keyVM.ssKey.mode = .reactive
//            keyVM.ssKey.main = newRestColor
//            keyVM.ssKey.active = newActiveColor
//            keyVM.ssKey.duration = UInt16(newSpeed)
//        }
//    }
//
//    // MARK: - Disabled
//
//    private func handleDisabled() {
//        selectedKeyModels.forEach { keyViewModel in
//            keyViewModel.ssKey.mode = .disabled
//        }
//    }
//}
