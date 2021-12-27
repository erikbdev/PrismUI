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
    }

    func apply(_ input: Input) {
        switch input {
        case .onAppear:
            onAppearSubject.send()
        case .onReactiveTouch(let index):
            onReactiveTouchSubject.send(index)
        }
    }

    // MARK: - Subjects

    private let onAppearSubject = PassthroughSubject<Void, Never>()
    private let onReactiveTouchSubject = PassthroughSubject<Int, Never>()

    // MARK: - Main Data

    @Published var keyModels: Set<KeyViewModel>
    @Published var currentColor = HSB(hue: 0, saturation: 1, brightness: 1)
    @Published var currentMode: SSKeyStruct.SSKeyModes = .steady
    @Published var disableColorPicker = false

    // Decides whether the update button should be active or not
    @Published var allowUpdatingDevice = true

    // If there are keys selection and the view has not reflected the data from the keys, this is true,
    // else it is false.
    private var settingViewFromSelection = false

    // If mode is changed, it will reset all values but we do not want to
    // get notified until the last value is reset so we can update the model
    private var modeCurrentlyChanging = false

    // This prevents ColorChanged being called repeatedly if a thumb was selected
    // and was setting the thumbs color to the color picker.
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

    @Published var waveModeOn = false
    @Published var waveDirection: SSKeyEffectStruct.SSPerKeyDirection = .xy
    @Published var waveControl: SSKeyEffectStruct.SSPerKeyControl = .inward
    @Published var pulse: CGFloat = 100
    @Published var origin: SSKeyEffectStruct.SSPoint = SSKeyEffectStruct.SSPoint() // TODO: Add origin for colorShift

    // MARK: Reactive Settings

    @Published var activeColor = RGB(red: 1.0, green: 0.0, blue: 0.0)
    @Published var restColor = RGB(red: 0.0, green: 0.0, blue: 0.0)

    init(keyModels: Set<KeyViewModel>) {
        self.keyModels = keyModels
        super.init()

        bindInputs()
    }

    private func bindInputs() {
        // Observe selectedMode and change view state
        $currentMode
            .receive(on: RunLoop.main)
            .sink { newMode in
                print("Will Change Mode")
                self.handleModeChanged(newMode: newMode)
                print("Changed Mode")
            }
            .store(in: &cancellables)

        // Steady Mode
        $currentColor
            .filter({ [weak self] _ in
                self?.currentMode == .steady && self?.modeCurrentlyChanging == false && self?.settingViewFromSelection == false
            })
            .sink { [weak self] newColor in
                print("Handle steady mode")
                self?.handleSteadyMode(newColor: newColor)
            }
            .store(in: &cancellables)

        // Color Shift Mode
        $colorSelectors
            .combineLatest($speed, $waveModeOn, $waveDirection, $waveControl, $pulse)
            .filter({ [weak self] _ in
                self?.currentMode == .colorShift && self?.modeCurrentlyChanging == false && self?.settingViewFromSelection == false
            })
            .sink { [weak self] (newColorSelectors,
                                 newSpeed,
                                 newWave,
                                 newWaveDirection,
                                 newWaveControl,
                                 newPulse) in
                print("Handle ColorShift")
                self?.handleColorShift(newSelectors: newColorSelectors, newSpeed: newSpeed)
            }
            .store(in: &cancellables)

        // Breathing Mode
        $colorSelectors
            .combineLatest($speed)
            .filter({ [weak self] _ in
                self?.currentMode == .breathing && self?.modeCurrentlyChanging == false && self?.settingViewFromSelection == false
            })
            .sink { [weak self] (newColorSelectors, newSpeed) in
                print("Handle Breathing")
                self?.handleBreathing(newSelectors: newColorSelectors, newSpeed: newSpeed)
            }
            .store(in: &cancellables)

        // Reactive Mode
        $activeColor
            .combineLatest($restColor, $speed)
            .filter({ [weak self] _ in
                self?.currentMode == .reactive && self?.modeCurrentlyChanging == false && self?.settingViewFromSelection == false
            })
            .sink { [weak self] (newActive, newRest, newSpeed) in
                print("Handle Reactive")
                self?.handleReactive(newActiveColor: newActive, newRestColor: newRest, newSpeed: newSpeed)
            }
            .store(in: &cancellables)

        // Disabled Mode
        $currentMode
            .filter({ [weak self] mode in mode == .disabled && self?.modeCurrentlyChanging == false && self?.settingViewFromSelection == false })
            .sink { mode in
                print("Handle Disabled, mode: \(mode)")
            }
            .store(in: &cancellables)

        onReactiveTouchSubject
            .sink { [weak self] index in
                print("Reactive touched")
                self?.thumbSelected = self?.thumbSelected == index ? -1 : index
            }
            .store(in: &cancellables)

        // Handle thumb clicked and set selector's color to color picker
        $thumbSelected
            .filter({ $0 != -1 })
            .receive(on: RunLoop.main)
            .sink { [weak self] (index) in
                guard let `self` = self else { return }
                print("Handle thumb selected.")
                switch self.currentMode {
                case .colorShift, .breathing:
                    self.thumbColorSet = true // This omits repeated currentColor for thumb
                    self.currentColor = self.colorSelectors[index].rgb.hsv
                case .reactive:
                    self.thumbColorSet = true // This omits repeated currentColor for thumb
                    if index == 0 {
                        self.currentColor = self.activeColor.hsv
                    } else {
                        self.currentColor = self.restColor.hsv
                    }
                default:
                    break
                }
            }
            .store(in: &cancellables)

        // Handle color picker changed if thumb is selected
        $currentColor
            .receive(on: RunLoop.main)
            .sink { [weak self] (color) in
                guard let `self` = self else { return }
                guard !self.thumbColorSet else { self.thumbColorSet = false; return }
                let selected = self.thumbSelected
                guard selected != -1 else { return }
                print("Handle color changed for thumb.")
                switch self.currentMode {
                case .breathing, .colorShift:
                    self.colorSelectors[selected].rgb = color.rgb
                case .reactive:
                    if selected == 0 {
                        self.activeColor = color.rgb
                    } else {
                        self.restColor = color.rgb
                    }
                default:
                    break
                }
            }
            .store(in: &cancellables)

        // TODO: Get settings to reflect based on selection
//        $keyModels
//            .removeDuplicates()
//            .sink { [weak self] newData in
//                print("Will Handle Key selection changed")
//                self?.handleKeysSelectedChanged(newModels: newData)
//                print("Did handle Key selectioin changed")
//            }
//            .store(in: &cancellables)
    }

    private func handleKeysSelectedChanged(newModels: Set<KeyViewModel>) {
        guard let firstKeyModel = newModels.first else { return }
        let allSatisfy = newModels.allSatisfy({ $0.ssKey.sameEffect(as: firstKeyModel.ssKey) })
        settingViewFromSelection = true
        // Set main color picker based on mode
        if allSatisfy, let firstKeyModel = newModels.first {
            currentMode = firstKeyModel.ssKey.mode
            switch firstKeyModel.ssKey.mode {
            case .steady:
                currentColor = firstKeyModel.ssKey.main.hsv
                break
            case .reactive:
                activeColor = firstKeyModel.ssKey.active
                restColor = firstKeyModel.ssKey.main
                speed = CGFloat(firstKeyModel.ssKey.duration)
            default:
                break
            }
        } else {
            currentMode = .mixed
            currentColor = HSB(hue: 0, saturation: 0, brightness: 0)
            disableColorPicker = true
        }
        settingViewFromSelection = false
    }

    private func handleModeChanged(newMode: SSKeyStruct.SSKeyModes) {
        modeCurrentlyChanging = true
        commonSwitch()

        switch newMode {
        case SSKeyStruct.SSKeyModes.steady:
            switchToSteady()
        case SSKeyStruct.SSKeyModes.colorShift:
            switchToColorShift()
        case SSKeyStruct.SSKeyModes.breathing:
            switchToBreathing()
        case SSKeyStruct.SSKeyModes.reactive:
            switchToReactive()
        case SSKeyStruct.SSKeyModes.disabled:
            switchToDisabled()
        default:
            switchToMixed()
        }
    }

    // MARK: - Steady Mode

    private func switchToSteady() {
        allowUpdatingDevice = true

        modeCurrentlyChanging = false // This will allow to update keys to this mode
        currentColor = HSB(hue: 0, saturation: 1, brightness: 1)
    }

    private func handleSteadyMode(newColor: HSB) {
        keyModels.forEach { keyModel in
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
        allowUpdatingDevice = false

        gradientSliderMode = .gradient
        colorSelectors = [
            ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.88), position: 0),
            ColorSelector(rgb: .init(red: 1.0, green: 0xea/0xff, blue: 0.0), position: 0.32),
            ColorSelector(rgb: .init(red: 0.0, green: 0xcc/0xff, blue: 1.0), position: 0.76)
        ]
        speed = 3000
        speedRange = 1000...30000
        waveModeOn = false
        waveControl = .inward
        waveDirection = .xy
        modeCurrentlyChanging = false // This will allow to update keys to this mode
        pulse = 100
    }

    private func handleColorShift(newSelectors: [ColorSelector], newSpeed: CGFloat) {
        keyModels.forEach { keyModel in
        }
    }

    // MARK: - Breathing

    private func switchToBreathing() {
        allowUpdatingDevice = false

        gradientSliderMode = .breathing
        speed = 4000
        speedRange = 2000...30000
        modeCurrentlyChanging = false // This will allow to update keys to this mode
        colorSelectors = [
            ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.0), position: 0)
        ]
    }

    private func handleBreathing(newSelectors: [ColorSelector], newSpeed: CGFloat) {
        guard settingViewFromSelection else { return }
    }

    // MARK: - Reactive

    private func switchToReactive() {
        allowUpdatingDevice = true

        currentColor = HSB(hue: 0, saturation: 1, brightness: 1)

        // These value changes will notify our listeners
        speedRange = 100...1000
        speed = 300
        restColor = .init(red: 0, green: 0, blue: 0)
        modeCurrentlyChanging = false // This will allow to update keys to this mode
        activeColor = .init(red: 1.0, green: 0, blue: 0)
    }

    private func handleReactive(newActiveColor: RGB, newRestColor: RGB, newSpeed: CGFloat) {
        keyModels.forEach { keyVM in
            keyVM.ssKey.mode = .reactive
            keyVM.ssKey.main = restColor
            keyVM.ssKey.active = activeColor
            keyVM.ssKey.duration = UInt16(newSpeed)
        }
    }

    // MARK: - Disabled

    private func switchToDisabled() {
        allowUpdatingDevice = true
        disableColorPicker = true
        currentColor = .init(hue: 0, saturation: 0, brightness: 0)
    }

    private func handleDisabled() {
        keyModels.forEach { keyViewModel in
            keyViewModel.ssKey.mode = .disabled
        }
    }

    // MARK: - Mixed

    private func switchToMixed() {
        disableColorPicker = true
        allowUpdatingDevice = false
    }

    private func createEffect() {
    }
}
