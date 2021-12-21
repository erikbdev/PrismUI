//
//  PerKeyKeyboardViewModel.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/1/21.
//

import Foundation
import PrismKit
import Combine

final class PerKeyKeyboardDeviceViewModel: DeviceViewModel, UniDirectionalDataFlowType {
    typealias InputType = Input

    // MARK: Input
    enum Input {
        case onAppear
    }

    func apply(_ input: Input) {
        switch input {
        case .onAppear:
            onAppearSubject.send()
        }
    }

    @Published var updateKeyboard = false
    @Published var finishedLoading = false
    @Published var selected = Set<SSKey>()
    @Published var keyModels = [KeyViewModel]()

    private(set) var keyboardMap: [[CGFloat]] = []
    private(set) var keyboardRegionAndKeyCodes: [[(UInt8, UInt8)]] = []

    private let onAppearSubject = PassthroughSubject<Void, Never>()

    override init(ssDevice: SSDevice) {
        super.init(ssDevice: ssDevice)
        bindInputs()
        bindOutputs()
    }

    private func bindInputs() {
        onAppearSubject.sink { [weak self] _ in
            self?.loadKeyboardMap()
            self?.loadKeyboardRegionAndKeyCodes()
            self?.prepareKeyViewModel()
            self?.finishedLoading = true
        }
        .store(in: &cancellables)
    }

    private func prepareKeyViewModel() {
        guard let property = ssDevice.properties as? SSPerKeyProperties else { return }

        for row in keyboardRegionAndKeyCodes {
            for element in row {
                if let key = property.keys.first(where: {
                    $0.region == element.0 &&
                    $0.keycode == element.1
                }) {
                    let keyViewModel = KeyViewModel(ssKey: key)
                    keyViewModel.$selected
                        .removeDuplicates()
                        .receive(on: RunLoop.main)
                        .sink(receiveValue: { [weak self] isSelected in
                            guard let `self` = self else { return }
                            if isSelected {
                                self.selected.insert(keyViewModel.ssKey)
                            } else {
                                self.selected.remove(keyViewModel.ssKey)
                            }
                        })
                        .store(in: &cancellables)
                    keyModels.append(keyViewModel)
                }
            }
        }
    }

    private func bindOutputs() {
        // TODO: Empty Output
    }

    private func loadKeyboardMap() {
        switch (model) {
        case .perKey:
            keyboardMap.append(contentsOf: SSPerKeyProperties.perKeyMap)
        case .perKeyGS65:
            keyboardMap.append(contentsOf: SSPerKeyProperties.perKeyGS65KeyMap)
        default:
            break
        }
    }

    private func loadKeyboardRegionAndKeyCodes() {
        switch (model) {
        case .perKey:
            keyboardRegionAndKeyCodes.append(contentsOf: SSPerKeyProperties.perKeyRegionKeyCodes)
        case .perKeyGS65:
            keyboardRegionAndKeyCodes.append(contentsOf: SSPerKeyProperties.perKeyGS65RegionKeyCodes)
        default:
            break
        }
    }

    func update(force: Bool = true) {
        ssDevice.update(force: force)
    }
}
