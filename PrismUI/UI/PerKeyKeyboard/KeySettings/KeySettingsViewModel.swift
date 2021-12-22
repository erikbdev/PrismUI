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

    @Published var keyModels: OrderedSet<KeyViewModel>

    @Published var currentColor = HSV(hue: 0, saturation: 0, brightness: 1) {
        didSet {
            handleColorChanged()
        }
    }

    @Published var mode: Int = 0 {
        didSet {
            handleModeChanged()
        }
    }

    @Published var disableColorPicker = false

    @Published var allowUpdatingDevice = true

    private var allowEdits = false
    private let onAppearSubject = PassthroughSubject<Void, Never>()

    init(keyModels: OrderedSet<KeyViewModel>) {
        self.keyModels = keyModels
        super.init()

        bindInputs()
    }

    private func bindInputs() {
        onAppearSubject
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                let allSatisfy = self.keyModels.allSatisfy({ $0.ssKey.sameEffect(as: self.keyModels.first!.ssKey) })

                // Set main color picker based on mode
                if allSatisfy, let firstKeyModel = self.keyModels.first {
                    self.mode = firstKeyModel.ssKey.mode.rawValue
                    self.currentColor = firstKeyModel.ssKey.main.hsv
                } else {
                    self.currentColor = HSV(hue: 0, saturation: 0, brightness: 1)
                    self.mode = 5
                }
                self.allowEdits = true
            }
            .store(in: &cancellables)
    }

    private func handleColorChanged() {
        switch mode {
        case SSKey.SSKeyModes.steady.rawValue:
            handleSteadyMode()
        case SSKey.SSKeyModes.colorShift.rawValue:
            handleColorShift()
        case SSKey.SSKeyModes.breathing.rawValue:
            handleBreathing()
        case SSKey.SSKeyModes.reactive.rawValue:
            handleReactive()
        case SSKey.SSKeyModes.disabled.rawValue:
            handleDisabled()
        default:
            break
        }
    }

    private func handleModeChanged() {
        commonSwitch()

        switch mode {
        case SSKey.SSKeyModes.steady.rawValue:
            switchToSteady()
        case SSKey.SSKeyModes.colorShift.rawValue:
            switchToColorShift()
        case SSKey.SSKeyModes.breathing.rawValue:
            switchToBreathing()
        case SSKey.SSKeyModes.reactive.rawValue:
            switchToReactive()
        case SSKey.SSKeyModes.disabled.rawValue:
            switchToDisabled()
        default:
            handleMixed()
        }
    }

    // MARK: - Steady Mode

    private func switchToSteady() {
        allowUpdatingDevice = true
        currentColor = HSV(hue: 0, saturation: 1, brightness: 1)
        handleSteadyMode()
    }

    private func handleSteadyMode() {
        guard allowEdits else { return }
        keyModels.forEach { keyModel in
            keyModel.ssKey.mode = .steady
            keyModel.ssKey.main = currentColor.rgb
            keyModel.objectWillChange.send()
        }
    }

    private func commonSwitch() {
        disableColorPicker = false
    }

    // MARK: - Color Shift

    private func switchToColorShift() {
        allowUpdatingDevice = false
    }

    private func handleColorShift() {
        guard allowEdits else { return }

    }

    // MARK: - Breathing

    private func switchToBreathing() {
        allowUpdatingDevice = false

    }

    private func handleBreathing() {
        guard allowEdits else { return }

    }

    // MARK: - Reactive

    private func switchToReactive() {
        allowUpdatingDevice = false

    }

    private func handleReactive() {
        guard allowEdits else { return }

    }

    // MARK: - Disabled
    private func switchToDisabled() {
        allowUpdatingDevice = false

    }

    private func handleDisabled() {
        guard allowEdits else { return }

    }

    // MARK: - Mixed

    private func handleMixed() {
        disableColorPicker = true
        allowUpdatingDevice = false
    }
}
