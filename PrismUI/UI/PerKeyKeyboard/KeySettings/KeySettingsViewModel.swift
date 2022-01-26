//
//  KeySettingsViewModel.swift
//  PrismUI
//
//  Created by Erik Bautista on 12/20/21.
//

import Combine
import PrismKit
import OrderedCollections

final class KeySettingsViewModel: BaseViewModel, UniDirectionalDataFlowType {
    typealias InputType = Input

    enum Input {
        case onAppear
        case onReactiveTouch(index: Int)
        case onShowOrigin
    }

    func apply(_ input: Input) {
        switch input {
        case .onAppear:
            onAppearSubject.send()
        case .onReactiveTouch(let index):
            onReactiveTouchSubject.send(index)
        case .onShowOrigin:
            onShowOriginSubject.send()
        }
    }

    // MARK: - Subjects

    private let onAppearSubject = PassthroughSubject<Void, Never>()
    private let onReactiveTouchSubject = PassthroughSubject<Int, Never>()
    private let onShowOriginSubject = PassthroughSubject<Void, Never>()

    // MARK: - Main Data

    @Published var selectedKeyModels: Set<KeyViewModel>
    @Published var selectedColor = HSB(hue: 0, saturation: 1, brightness: 1)
    @Published var selectedMode: SSKey.SSKeyModes = .steady
    @Published var disableColorPicker = false

    // Decides whether the update button should be active or not
    @Published var allowUpdatingDevice = true

    private var skipDefaultValues = false

    // If `selectedKeyModels` array is changed, we want to copy the value from the model to our view, but
    // we do not want our view inputs to change our model while this is happening.
    private var settingModelToView = false

    // If mode is changed, it will reset all values but we do not want to
    // get notified until the last value is reset so we can update the model
    private var modeChanging = false

    // If our thumbSelection changes, we want to set the color of the thumb to the color
    // picker, but we do not want to allow the color picker to change the color for the initial state.
    private var thumbColorSet = false

    // MARK: - Effects

    // MARK: Common Effect Settings

    @Published var speed: CGFloat = 3000 // Speed Settings
    @Published var speedRange: ClosedRange<CGFloat> = 1000...30000

    // MARK: Common Color Shift and Breathing

    @Published var gradientSliderMode: MultiColorSliderBackgroundStyle = .gradient
    @Published var colorSelectors = [ColorSelector(rgb: .init(red: 1.0, green: 1.0, blue: 1.0), position: 0),
                                ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.0), position: 0)] // Just for testing, shouldn't be shown
    @Published var thumbSelected: Int = -1

    // MARK: Color Shift Settings

    @Published var showOriginModal = false
    @Published var waveActive = false
    @Published var waveDirection: SSKeyEffect.SSPerKeyDirection = .xy
    @Published var waveControl: SSKeyEffect.SSPerKeyControl = .inward
    @Published var pulse: CGFloat = 100
    @Published var origin: SSKeyEffect.SSPoint = SSKeyEffect.SSPoint() // TODO: Add origin for colorShift

    // MARK: Reactive Settings

    @Published var activeColor = RGB(red: 1.0, green: 0.0, blue: 0.0)
    @Published var restColor = RGB(red: 0.0, green: 0.0, blue: 0.0)

    var updateDevice: () -> ()

    init(keyModels: Set<KeyViewModel>, updateDevice: @escaping () -> ()) {
        self.selectedKeyModels = keyModels
        self.updateDevice = updateDevice
        super.init()

        bind()
    }

    private func bind() {
        onAppearSubject
            .sink { _ in
                
            }
            .store(in: &cancellables)

        onShowOriginSubject
            .sink { _ in
                
            }
            .store(in: &cancellables)

        // Observe selectedMode and change view state on main thread.
        $selectedMode
            .receive(on: RunLoop.main)
            .sink { [weak self] newMode in
                self?.handleModeChanged(newMode: newMode)
            }
            .store(in: &cancellables)

        // Steady Mode
        $selectedColor
            .filter({ [weak self] _ in
                self?.selectedMode == .steady &&
                self?.modeChanging == false &&
                self?.settingModelToView == false &&
                self?.selectedKeyModels.count ?? 0 > 0
            })
            .sink { [weak self] newColor in
//                print("Update Steady")
                self?.handleSteadyMode(newColor: newColor)
                self?.updateDevice()
            }
            .store(in: &cancellables)

        // Color Shift Mode
        $colorSelectors
            .combineLatest($speed, $waveActive, $waveDirection, $waveControl, $pulse, $origin)
            .filter({ [weak self] _ in
                self?.selectedMode == .colorShift &&
                self?.modeChanging == false &&
                self?.settingModelToView == false &&
                self?.selectedKeyModels.count ?? 0 > 0
            })
            .sink { [weak self] (newColorSelectors,
                                 newSpeed,
                                 newWave,
                                 newWaveDirection,
                                 newWaveControl,
                                 newPulse,
                                 newOrigin) in
//                print("Update Color Shift")
                self?.handleColorShift(newSelectors: newColorSelectors,
                                       newSpeed: newSpeed,
                                       newWave: newWave,
                                       newWaveDirection: newWaveDirection,
                                       newWaveControl: newWaveControl,
                                       newOrigin: newOrigin,
                                       newPulse: newPulse)
                self?.updateDevice()
            }
            .store(in: &cancellables)

        // Breathing Mode
        $colorSelectors
            .combineLatest($speed)
            .filter({ [weak self] _ in
                self?.selectedMode == .breathing &&
                self?.modeChanging == false &&
                self?.settingModelToView == false &&
                self?.selectedKeyModels.count ?? 0 > 0
            })
            .sink { [weak self] (newColorSelectors, newSpeed) in
//                print("Update Breathing")
                self?.handleBreathing(newSelectors: newColorSelectors, newSpeed: newSpeed)
                self?.updateDevice()
            }
            .store(in: &cancellables)

        // Reactive Mode
        $activeColor
            .combineLatest($restColor, $speed)
            .filter({ [weak self] _ in
                self?.selectedMode == .reactive &&
                self?.modeChanging == false &&
                self?.settingModelToView == false &&
                self?.selectedKeyModels.count ?? 0 > 0
            })
            .sink { [weak self] (newActive, newRest, newSpeed) in
//                print("Update Reactive")
                self?.handleReactive(newActiveColor: newActive, newRestColor: newRest, newSpeed: newSpeed)
                self?.updateDevice()
            }
            .store(in: &cancellables)

        // Disabled Mode
        $selectedMode
            .filter({ [weak self] mode in
                mode == .disabled &&
                self?.modeChanging == false &&
                self?.settingModelToView == false &&
                self?.selectedKeyModels.count ?? 0 > 0
            })
            .sink { [weak self] _ in
//                print("Update Disabled")
                self?.handleDisabled()
                self?.updateDevice()
            }
            .store(in: &cancellables)

        onReactiveTouchSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] index in
                self?.thumbSelected = self?.thumbSelected == index ? -1 : index
            }
            .store(in: &cancellables)

        // Handle thumb clicked and set selector's color to color picker
        $thumbSelected
            .filter({ $0 != -1 })
            .receive(on: RunLoop.main)
            .sink { [weak self] newIndex in
                self?.handleThumbSelected(newIndex: newIndex)
            }
            .store(in: &cancellables)

        // Handle color picker changed if thumb is selected
        $selectedColor
            .filter({ [weak self] _ in self?.thumbSelected != -1 })
            .receive(on: RunLoop.main)
            .sink { [weak self] newColor in
                self?.handleColorChangedForThumb(newColor: newColor)
            }
            .store(in: &cancellables)

        // Get settings to reflect based on selection
        $selectedKeyModels
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] newData in
                self?.handleKeysSelectedChanged(newModels: newData)
            }
            .store(in: &cancellables)
    }

    private func handleThumbSelected(newIndex: Int) {
        switch selectedMode {
        case .colorShift, .breathing:
            thumbColorSet = true // This omits repeated currentColor for thumb
            selectedColor = self.colorSelectors[newIndex].rgb.hsv
        case .reactive:
            self.thumbColorSet = true // This omits repeated currentColor for thumb
            if newIndex == 0 {
                selectedColor = activeColor.hsv
            } else {
                selectedColor = restColor.hsv
            }
        default:
            break
        }
    }

    private func handleColorChangedForThumb(newColor: HSB) {
        guard !thumbColorSet else { thumbColorSet = false; return }
        let selected = thumbSelected
//        print("Handle color changed for thumb.")
        switch selectedMode {
        case .breathing, .colorShift:
            colorSelectors[selected].rgb = newColor.rgb
        case .reactive:
            if selected == 0 {
                activeColor = newColor.rgb
            } else {
                restColor = newColor.rgb
            }
        default:
            break
        }
    }

    private func handleKeysSelectedChanged(newModels: Set<KeyViewModel>) {
        thumbSelected = -1
        guard let firstKeyModel = newModels.first else { return }
        let allSatisfy = newModels.allSatisfy({ $0.ssKey.sameEffect(as: firstKeyModel.ssKey) })

        skipDefaultValues = true

        // Set main color picker based on mode
        if allSatisfy, let firstKeyModel = newModels.first {
            settingModelToView = true
            selectedMode = firstKeyModel.ssKey.mode
            disableColorPicker = false

            switch firstKeyModel.ssKey.mode {
            case .steady:
                selectedColor = firstKeyModel.ssKey.main.hsv
            case .colorShift:
                if let effect = firstKeyModel.ssKey.effect {
                    colorSelectors = effect.transitions
                        .compactMap({ ColorSelector(rgb: $0.color, position: $0.position) })
                    speed = CGFloat(effect.duration)
                    waveActive = effect.waveActive
                    waveDirection = effect.direction
                    waveControl = effect.control
                    origin = effect.origin
                    pulse = CGFloat(effect.pulse)
                }
            case .breathing:
                if let effect = firstKeyModel.ssKey.effect {
                    colorSelectors = effect.transitions
                        .enumerated()
                        .filter({ $0.offset % 2 == 0 })
                        .compactMap({ $0.element })
                        .compactMap({ ColorSelector(rgb: $0.color, position: $0.position) })
                    speed = CGFloat(effect.duration)
                }
            case .reactive:
                activeColor = firstKeyModel.ssKey.active
                restColor = firstKeyModel.ssKey.main
                speed = CGFloat(firstKeyModel.ssKey.duration)
            default:
                break
            }
        } else {
            selectedMode = .mixed
            selectedColor = HSB(hue: 0, saturation: 0, brightness: 0)
            disableColorPicker = true
        }
        settingModelToView = false
    }

    private func handleModeChanged(newMode: SSKey.SSKeyModes) {
        guard !skipDefaultValues else { skipDefaultValues = false; return }
        modeChanging = true
        commonSwitch()

        switch newMode {
        case SSKey.SSKeyModes.steady:
            switchToSteady()
        case SSKey.SSKeyModes.colorShift:
            switchToColorShift()
        case SSKey.SSKeyModes.breathing:
            switchToBreathing()
        case SSKey.SSKeyModes.reactive:
            switchToReactive()
        case SSKey.SSKeyModes.disabled:
            switchToDisabled()
        default:
            switchToMixed()
        }
    }

    // MARK: - Steady Mode

    private func switchToSteady() {
        allowUpdatingDevice = true

        modeChanging = false // This will allow to update keys to this mode
        selectedColor = HSB(hue: 0, saturation: 1, brightness: 1)
    }

    private func handleSteadyMode(newColor: HSB) {
        selectedKeyModels.forEach { keyModel in
            keyModel.ssKey.mode = .steady
            keyModel.ssKey.main = newColor.rgb
        }
    }

    private func commonSwitch() {
        disableColorPicker = false
        thumbSelected = -1
    }

    // MARK: - Color Shift

    private func switchToColorShift() {
        allowUpdatingDevice = true

        gradientSliderMode = .gradient
        colorSelectors = [
            ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.88), position: 0),
            ColorSelector(rgb: .init(red: 1.0, green: 0xea/0xff, blue: 0.0), position: 0.32),
            ColorSelector(rgb: .init(red: 0.0, green: 0xcc/0xff, blue: 1.0), position: 0.76)
        ]
        speed = 3000
        speedRange = 1000...30000
        waveActive = false
        waveControl = .inward
        waveDirection = .xy
        modeChanging = false // This will allow to update keys to this mode
        pulse = 100
    }

    private func handleColorShift(newSelectors: [ColorSelector],
                                  newSpeed: CGFloat,
                                  newWave: Bool,
                                  newWaveDirection: SSKeyEffect.SSPerKeyDirection,
                                  newWaveControl: SSKeyEffect.SSPerKeyControl,
                                  newOrigin: SSKeyEffect.SSPoint,
                                  newPulse: CGFloat) {
        // TODO: Handle generating id for effect
        let transitions = newSelectors.compactMap({ SSKeyEffect.SSPerKeyTransition(color: $0.rgb, position: $0.position) })
            .sorted(by: { $0.position < $1.position })

        guard transitions.count > 0 else { return }

        var effect = SSKeyEffect(id: 0,
                                 transitions: transitions)

        effect.start = transitions[0].color
        effect.duration = UInt16(newSpeed)
        effect.waveActive = newWave
        effect.direction = newWaveDirection
        effect.control = newWaveControl
        effect.origin = newOrigin
        effect.pulse = UInt16(newPulse)

        selectedKeyModels.forEach { keyModel in
            keyModel.ssKey.mode = .colorShift
            keyModel.ssKey.effect = effect
            keyModel.ssKey.main = effect.start
        }
    }

    // MARK: - Breathing

    private func switchToBreathing() {
        allowUpdatingDevice = true

        gradientSliderMode = .breathing
        speed = 4000
        speedRange = 2000...30000
        modeChanging = false // This will allow to update keys to this mode
        colorSelectors = [
            ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.0), position: 0)
        ]
    }

    private func handleBreathing(newSelectors: [ColorSelector], newSpeed: CGFloat) {
        // TODO: Add missing values to the selector
        let baseTransitions = newSelectors.compactMap({ SSKeyEffect.SSPerKeyTransition(color: $0.rgb, position: $0.position) })
            .sorted(by: { $0.position < $1.position })

        guard baseTransitions.count > 0 else { return }

        var transitions: [SSKeyEffect.SSPerKeyTransition] = []

        // We add the transitions from baseTransition and also add the half values between
        // each transition to have the breathing effect.
        for inx in baseTransitions.indices {
            let firstSelector = baseTransitions[inx]
            transitions.append(firstSelector)

            var halfDistance: CGFloat
            if (inx + 1) < baseTransitions.count {
                let secondSelector = baseTransitions[inx + 1]
                halfDistance = (secondSelector.position + firstSelector.position) / 2
            } else {
                halfDistance = (1 + firstSelector.position) / 2
            }

            transitions.append(SSKeyEffect.SSPerKeyTransition(color: RGB(), position: halfDistance))
        }

        var effect = SSKeyEffect(id: 0,
                                 transitions: transitions)

        effect.start = transitions[0].color
        effect.duration = UInt16(newSpeed)

        selectedKeyModels.forEach { keyModel in
            keyModel.ssKey.mode = .breathing
            keyModel.ssKey.effect = effect
            keyModel.ssKey.main = effect.start
        }
    }

    // MARK: - Reactive

    private func switchToReactive() {
        allowUpdatingDevice = true

        selectedColor = HSB(hue: 0, saturation: 1, brightness: 1)

        // These value changes will notify our listeners
        speedRange = 100...1000
        speed = 300
        restColor = RGB(red: 0, green: 0, blue: 0)
        modeChanging = false // This will allow to update keys to this mode
        activeColor = RGB(red: 1.0, green: 0, blue: 0)
    }

    private func handleReactive(newActiveColor: RGB, newRestColor: RGB, newSpeed: CGFloat) {
        selectedKeyModels.forEach { keyVM in
            keyVM.ssKey.mode = .reactive
            keyVM.ssKey.main = newRestColor
            keyVM.ssKey.active = newActiveColor
            keyVM.ssKey.duration = UInt16(newSpeed)
        }
    }

    // MARK: - Disabled

    private func switchToDisabled() {
        allowUpdatingDevice = true
        disableColorPicker = true
        selectedColor = .init(hue: 0, saturation: 0, brightness: 0)
    }

    private func handleDisabled() {
        selectedKeyModels.forEach { keyViewModel in
            keyViewModel.ssKey.mode = .disabled
        }
    }

    // MARK: - Mixed

    private func switchToMixed() {
        allowUpdatingDevice = false
        disableColorPicker = true
        selectedColor = HSB()
    }
}
