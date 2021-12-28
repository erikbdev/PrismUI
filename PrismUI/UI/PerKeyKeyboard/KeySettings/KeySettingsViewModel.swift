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

    @Published var selectedKeyModels: Set<KeyViewModel>
    @Published var selectedColor = HSB(hue: 0, saturation: 1, brightness: 1)
    @Published var selectedMode: SSKeyStruct.SSKeyModes = .steady
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

    @Published var waveModeOn = false
    @Published var waveDirection: SSKeyEffectStruct.SSPerKeyDirection = .xy
    @Published var waveControl: SSKeyEffectStruct.SSPerKeyControl = .inward
    @Published var pulse: CGFloat = 100
    @Published var origin: SSKeyEffectStruct.SSPoint = SSKeyEffectStruct.SSPoint() // TODO: Add origin for colorShift

    // MARK: Reactive Settings

    @Published var activeColor = RGB(red: 1.0, green: 0.0, blue: 0.0)
    @Published var restColor = RGB(red: 0.0, green: 0.0, blue: 0.0)

    init(keyModels: Set<KeyViewModel>) {
        self.selectedKeyModels = keyModels
        super.init()

        bind()
    }

    private func bind() {
        // Observe selectedMode and change view state on main thread.
        $selectedMode
            .filter({ [weak self] _ in
                guard let skipDefaultValue = self?.skipDefaultValues else { return false }
                if skipDefaultValue {
                    self?.skipDefaultValues = false // Handled skip, so set to false
                }
                return !skipDefaultValue
            })
            .receive(on: RunLoop.main)
            .sink { [weak self] newMode in
//                print("Will Change Mode")
                self?.handleModeChanged(newMode: newMode)
//                print("Changed Mode")
            }
            .store(in: &cancellables)

        // Steady Mode on background thread.
        $selectedColor
            .filter({ [weak self] _ in
                self?.selectedMode == .steady && self?.modeChanging == false && self?.settingModelToView == false
            })
            .sink { [weak self] newColor in
//                print("Handle steady mode")
                self?.handleSteadyMode(newColor: newColor)
            }
            .store(in: &cancellables)

        // Color Shift Mode
        $colorSelectors
            .combineLatest($speed, $waveModeOn, $waveDirection, $waveControl, $pulse)
            .filter({ [weak self] _ in
                self?.selectedMode == .colorShift && self?.modeChanging == false && self?.settingModelToView == false
            })
            .sink { [weak self] (newColorSelectors,
                                 newSpeed,
                                 newWave,
                                 newWaveDirection,
                                 newWaveControl,
                                 newPulse) in
//                print("Handle ColorShift")
                self?.handleColorShift(newSelectors: newColorSelectors,
                                       newSpeed: newSpeed,
                                       newWave: newWave,
                                       newWaveDirection: newWaveDirection,
                                       newWaveControl: newWaveControl,
                                       newPulse: newPulse)
            }
            .store(in: &cancellables)

        // Breathing Mode
        $colorSelectors
            .combineLatest($speed)
            .filter({ [weak self] _ in
                self?.selectedMode == .breathing && self?.modeChanging == false && self?.settingModelToView == false
            })
            .sink { [weak self] (newColorSelectors, newSpeed) in
//                print("Handle Breathing")
                self?.handleBreathing(newSelectors: newColorSelectors, newSpeed: newSpeed)
            }
            .store(in: &cancellables)

        // Reactive Mode
        $activeColor
            .combineLatest($restColor, $speed)
            .filter({ [weak self] _ in
                self?.selectedMode == .reactive && self?.modeChanging == false && self?.settingModelToView == false
            })
            .sink { [weak self] (newActive, newRest, newSpeed) in
//                print("Handle Reactive")
                self?.handleReactive(newActiveColor: newActive, newRestColor: newRest, newSpeed: newSpeed)
            }
            .store(in: &cancellables)

        // Disabled Mode
        $selectedMode
            .filter({ [weak self] mode in mode == .disabled && self?.modeChanging == false && self?.settingModelToView == false })
            .sink { [weak self] _ in
//                print("Handle Disabled")
                self?.handleDisabled()
            }
            .store(in: &cancellables)

        onReactiveTouchSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] index in
//                print("Will handle reactive touched")
                self?.thumbSelected = self?.thumbSelected == index ? -1 : index
//                print("Did handle reactive touched")
            }
            .store(in: &cancellables)

        // Handle thumb clicked and set selector's color to color picker
        $thumbSelected
            .filter({ $0 != -1 })
            .receive(on: RunLoop.main)
            .sink { [weak self] newIndex in
//                print("Will handle thumb selected.")
                self?.handleThumbSelected(newIndex: newIndex)
//                print("Did handle thumb selected.")
            }
            .store(in: &cancellables)

        // Handle color picker changed if thumb is selected
        $selectedColor
            .filter({ [weak self] _ in self?.thumbSelected != -1 })
            .receive(on: RunLoop.main)
            .sink { [weak self] newColor in
//                print("Will handle color changed for thumb")
                self?.handleColorChangedForThumb(newColor: newColor)
//                print("Did handle color changed for thumb")
            }
            .store(in: &cancellables)

        // Get settings to reflect based on selection
        $selectedKeyModels
            .removeDuplicates()
            .sink { [weak self] newData in
//                print("Will Handle Key selection changed")
                self?.handleKeysSelectedChanged(newModels: newData)
//                print("Did handle Key selectioin changed")
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

        // Set main color picker based on mode
        if allSatisfy, let firstKeyModel = newModels.first {
            skipDefaultValues = true
            settingModelToView = true

            selectedMode = firstKeyModel.ssKey.mode
            switch firstKeyModel.ssKey.mode {
            case .steady:
                selectedColor = firstKeyModel.ssKey.main.hsv
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

    private func handleModeChanged(newMode: SSKeyStruct.SSKeyModes) {
        modeChanging = true
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
        modeChanging = false // This will allow to update keys to this mode
        pulse = 100
    }

    private func handleColorShift(newSelectors: [ColorSelector],
                                  newSpeed: CGFloat,
                                  newWave: Bool,
                                  newWaveDirection: SSKeyEffectStruct.SSPerKeyDirection,
                                  newWaveControl: SSKeyEffectStruct.SSPerKeyControl,
                                  newPulse: CGFloat) {
        // TODO: Handle effect for color shift
        selectedKeyModels.forEach { keyModel in
        }
    }

    // MARK: - Breathing

    private func switchToBreathing() {
        allowUpdatingDevice = false

        gradientSliderMode = .breathing
        speed = 4000
        speedRange = 2000...30000
        modeChanging = false // This will allow to update keys to this mode
        colorSelectors = [
            ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.0), position: 0)
        ]
    }

    private func handleBreathing(newSelectors: [ColorSelector], newSpeed: CGFloat) {
        // TODO: Handle effect for breathing
        selectedKeyModels.forEach { keyModel in
        }
    }

    // MARK: - Reactive

    private func switchToReactive() {
        allowUpdatingDevice = true

        selectedColor = HSB(hue: 0, saturation: 1, brightness: 1)

        // These value changes will notify our listeners
        speedRange = 100...1000
        speed = 300
        restColor = .init(red: 0, green: 0, blue: 0)
        modeChanging = false // This will allow to update keys to this mode
        activeColor = .init(red: 1.0, green: 0, blue: 0)
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
        disableColorPicker = true
        allowUpdatingDevice = false
    }

    private func createEffect() {
    }
}
