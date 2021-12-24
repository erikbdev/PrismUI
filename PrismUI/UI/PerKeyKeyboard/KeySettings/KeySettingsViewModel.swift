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
    }

    func apply(_ input: Input) {
        switch input {
        case .onAppear:
            onAppearSubject.send()
        }
    }

    // MARK: - Device restrictions


    // MARK: - Main Data

    @Published var keyModels: OrderedSet<KeyViewModel>
    @Published var currentColor = HSB(hue: 0, saturation: 0, brightness: 1) {
        didSet { handleColorChanged(newColor: currentColor) }
    }
    @Published var currentMode: SSKeyStruct.SSKeyModes = .steady {
        didSet { handleModeChanged(newMode: currentMode) }
    }
    @Published var disableColorPicker = false
    @Published var allowUpdatingDevice = true // Decides whether the update button should be active or not
    private var allowModelEdits = false // Decides whether or not models are able to update the new models with data
    private let onAppearSubject = PassthroughSubject<Void, Never>()

    // MARK: - Effects

    // Common Effect Settings

    @Published var speed: CGFloat = 3000 // Speed Settings
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

    @Published var activeColor = HSB(hue: 0, saturation: 1, brightness: 1, alpha: 1.0)
    @Published var restingColor = HSB(hue: 0, saturation: 0, brightness: 0, alpha: 1.0)

    init(keyModels: OrderedSet<KeyViewModel>) {
        self.keyModels = keyModels
        super.init()

        bindInputs()
    }

    private func bindInputs() {
        onAppearSubject
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                guard let firstKeyModel = self.keyModels.first else { return }
                let allSatisfy = self.keyModels.allSatisfy({ $0.ssKey.sameEffect(as: firstKeyModel.ssKey) })

                // Set main color picker based on mode
                if allSatisfy, let firstKeyModel = self.keyModels.first {
                    self.currentMode = firstKeyModel.ssKey.mode
                    self.currentColor = firstKeyModel.ssKey.main.hsv
                } else {
                    self.currentColor = HSB(hue: 0, saturation: 0, brightness: 1)
                    self.currentMode = .mixed
                }
                self.allowModelEdits = true
            }
            .store(in: &cancellables)

        $thumbSelected
            .sink { [weak self] index in
                guard let `self` = self else { return }
                guard index != -1 else { return }
                switch self.currentMode {
                case .colorShift:
                    self.currentColor = self.colorSelectors[index].rgb.hsv
                    break
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    private func handleColorChanged(newColor: HSB) {
        switch currentMode {
        case .steady:
            handleSteadyMode(newColor: newColor)
        case .colorShift:
            handleColorShift(newColor: newColor)
        case .breathing:
            handleBreathing(newColor: newColor)
        case .reactive:
            handleReactive(newColor: newColor)
        case .disabled:
            handleDisabled()
        default:
            break
        }
    }

    private func handleModeChanged(newMode: SSKeyStruct.SSKeyModes) {
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
        currentColor = HSB(hue: 0, saturation: 1, brightness: 1)
    }

    private func handleSteadyMode(newColor: HSB) {
        guard allowModelEdits else { return }
        keyModels.forEach { keyModel in
            keyModel.ssKey.mode = .steady
            keyModel.ssKey.main = newColor.rgb
//            keyModel.objectWillChange.send()
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

    private func handleColorShift(newColor: HSB) {
        if thumbSelected != -1 {
            colorSelectors[thumbSelected].rgb = newColor.rgb
        }

        guard allowModelEdits else { return }

        keyModels.forEach { keyModel in
//            let keyEffect = SSKeyEffectStruct(identifier: 0, transitions: [])
            keyModel.ssKey.mode = .colorShift
//            keyModel.ssKey.effect = keyEffect
//            keyModel.objectWillChange.send()
        }
    }

    // MARK: - Breathing

    private func switchToBreathing() {
        allowUpdatingDevice = false

    }

    private func handleBreathing(newColor: HSB) {
        guard allowModelEdits else { return }

    }

    // MARK: - Reactive

    private func switchToReactive() {
        allowUpdatingDevice = false

    }

    private func handleReactive(newColor: HSB) {
        guard allowModelEdits else { return }

    }

    // MARK: - Disabled
    private func switchToDisabled() {
        allowUpdatingDevice = false

    }

    private func handleDisabled() {
        guard allowModelEdits else { return }

    }

    // MARK: - Mixed

    private func switchToMixed() {
        disableColorPicker = true
        allowUpdatingDevice = false
    }
}
