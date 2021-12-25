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

    // MARK: - Device restrictions


    // MARK: - Main Data

    @Published var keyModels: Set<KeyViewModel>
    @Published var currentColor = HSB(hue: 0, saturation: 0, brightness: 1) {
        didSet { handleColorChanged() }
    }
    @Published var currentMode: SSKeyStruct.SSKeyModes = .steady {
        didSet { handleModeChanged() }
    }
    @Published var disableColorPicker = false
    @Published var allowUpdatingDevice = true // Decides whether the update button should be active or not
    private var allowModelEdits = false // Decides whether or not models are able to update the new models with data

    // MARK: - Effects

    // Common Effect Settings

    @Published var speed: CGFloat = 3000 { // Speed Settings
        didSet {
            switch currentMode {
            case .colorShift:
                handleColorShift()
            case .breathing:
                handleBreathing()
            case .reactive:
                handleReactive()
            default:
                break
            }
        }
    }
    @Published var speedRange: ClosedRange<CGFloat> = 1000...30000

    // Common Color Shift and Breathing

    @Published var colorSelectors = [ColorSelector(rgb: .init(red: 1.0, green: 1.0, blue: 1.0), position: 0),
                                ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.0), position: 0)] // Just for testing, shouldn't be shown
    @Published var thumbSelected: Int = -1

    // Color Shift Settings

    @Published var waveModeOn = false
    @Published var waveDirection: SSKeyEffectStruct.SSPerKeyDirection = .xy
    @Published var waveControl: SSKeyEffectStruct.SSPerKeyControl = .inward
    @Published var pulse: CGFloat = 100
    @Published var origin: SSKeyEffectStruct.SSPoint = SSKeyEffectStruct.SSPoint() // TODO: Add origin for colorShift

    // Reactive Settings

    @Published var activeColor = RGB(red: 1.0, green: 0.0, blue: 0.0)
    @Published var restColor = RGB(red: 0.0, green: 0.0, blue: 0.0)

    init(keyModels: Set<KeyViewModel>) {
        self.keyModels = keyModels
        super.init()

        bindInputs()
    }

    private func bindInputs() {
        $keyModels
            .sink { [weak self] newData in
                self?.handleKeysSelectedChanged()
            }
            .store(in: &cancellables)

        $thumbSelected
            .sink { [weak self] index in
                guard let `self` = self else { return }
                guard index != -1 else { return }
                switch self.currentMode {
                case .colorShift:
                    self.currentColor = self.colorSelectors[index].rgb.hsv
                default:
                    break
                }
            }
            .store(in: &cancellables)

        onReactiveTouchSubject
            .sink { [weak self] index in
                if self?.thumbSelected == index {
                    self?.thumbSelected = -1
                } else {
                    self?.thumbSelected = index
                }
            }
            .store(in: &cancellables)
    }

    private func handleKeysSelectedChanged() {
        guard let firstKeyModel = keyModels.first else { return }
        let allSatisfy = keyModels.allSatisfy({ $0.ssKey.sameEffect(as: firstKeyModel.ssKey) })

        // Set main color picker based on mode
        if allSatisfy, let firstKeyModel = self.keyModels.first {
            currentMode = firstKeyModel.ssKey.mode
            switch firstKeyModel.ssKey.mode {
            case .steady:
                currentColor = firstKeyModel.ssKey.main.hsv
            case .reactive:
                activeColor = firstKeyModel.ssKey.active
                restColor = firstKeyModel.ssKey.main
                speed = CGFloat(firstKeyModel.ssKey.duration)
            default:
                break
            }
        } else {
            currentColor = HSB(hue: 0, saturation: 0, brightness: 0)
            currentMode = .mixed
            disableColorPicker = true
        }
        allowModelEdits = true
    }

    private func handleColorChanged() {
        switch currentMode {
        case .steady:
            handleSteadyMode()
        case .colorShift:
            handleColorShift()
        case .breathing:
            handleBreathing()
        case .reactive:
            handleReactive()
        case .disabled:
            handleDisabled()
        default:
            break
        }
    }

    private func handleModeChanged() {
        commonSwitch()

        switch currentMode {
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
        currentColor = HSB(hue: 0, saturation: 1, brightness: 1)
    }

    private func handleSteadyMode() {
        guard allowModelEdits else { return }
        keyModels.forEach { keyModel in
            keyModel.ssKey.mode = .steady
            keyModel.ssKey.main = currentColor.rgb
        }
    }

    private func commonSwitch() {
        disableColorPicker = false
        thumbSelected = -1
    }

    // MARK: - Color Shift

    private func switchToColorShift() {
        allowUpdatingDevice = false

        speed = 3000
        speedRange = 1000...30000
        waveModeOn = false
        waveControl = .inward
        waveDirection = .xy
        pulse = 100
        colorSelectors = [
            ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 0.88), position: 0),
            ColorSelector(rgb: .init(red: 1.0, green: 0xea/0xff, blue: 0.0), position: 0.32),
            ColorSelector(rgb: .init(red: 0.0, green: 0xcc/0xff, blue: 1.0), position: 0.76)
        ]
    }

    private func handleColorShift() {
        if thumbSelected != -1 {
            colorSelectors[thumbSelected].rgb = currentColor.rgb
        }

        guard allowModelEdits else { return }

        keyModels.forEach { keyModel in
//            let keyEffect = SSKeyEffectStruct(identifier: 0, transitions: [])
//            keyModel.ssKey.mode = .colorShift
//            keyModel.ssKey.effect = keyEffect
//            keyModel.objectWillChange.send()
        }
    }

    // MARK: - Breathing

    private func switchToBreathing() {
        allowUpdatingDevice = false

    }

    private func handleBreathing() {
        guard allowModelEdits else { return }

    }

    // MARK: - Reactive

    private func switchToReactive() {
        allowUpdatingDevice = true
        speedRange = 100...1000
        speed = 300
        restColor = .init(red: 0, green: 0, blue: 0)
        activeColor = .init(red: 1.0, green: 0, blue: 0)
        currentColor = HSB(hue: 0, saturation: 1, brightness: 1)
    }

    private func handleReactive() {
        if thumbSelected == 0 {
            activeColor = currentColor.rgb
        } else if thumbSelected == 1 {
            restColor = currentColor.rgb
        }

        guard allowModelEdits else { return }

        keyModels.forEach { keyVM in
            keyVM.ssKey.mode = .reactive
            keyVM.ssKey.main = restColor
            keyVM.ssKey.active = activeColor
            keyVM.ssKey.duration = UInt16(speed)
        }
    }

    // MARK: - Disabled
    private func switchToDisabled() {
        allowUpdatingDevice = true
        disableColorPicker = true
        currentColor = .init(hue: 0, saturation: 0, brightness: 0)
    }

    private func handleDisabled() {
        guard allowModelEdits else { return }

        keyModels.forEach { keyViewModel in
            keyViewModel.ssKey.mode = .disabled
        }
    }

    // MARK: - Mixed

    private func switchToMixed() {
        disableColorPicker = true
        allowUpdatingDevice = false
    }
}
