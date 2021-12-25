//
//  PerKeyKeyboardViewModel.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/1/21.
//

import Combine
import PrismKit

final class PerKeyKeyboardDeviceViewModel: DeviceViewModel, UniDirectionalDataFlowType {
    typealias InputType = Input

    // MARK: Input
    enum Input {
        case onAppear
        case onTouchOutside
        case onUpdateDevice
    }

    func apply(_ input: Input) {
        switch input {
        case .onAppear:
            onAppearSubject.send()
        case .onUpdateDevice:
            onUpdateDeviceSubject.send()
        case .onTouchOutside:
            onTouchOutsideSubject.send()
        }
    }

    @Published var finishedLoading = false
    @Published var selected = Set<KeyViewModel>()
    @Published var keyModels = [KeyViewModel]()
    @Published var mouseMode = 0
    @Published var containerDragShapeStart: CGPoint = .zero
    @Published var containerDragShapeEnd: CGSize = .zero

    private(set) var keyboardMap: [[CGFloat]] = []
    private(set) var keyboardRegionAndKeyCodes: [[(UInt8, UInt8)]] = []

    private let onAppearSubject = PassthroughSubject<Void, Never>()
    private let onUpdateDeviceSubject = PassthroughSubject<Void, Never>()
    private let onTouchOutsideSubject = PassthroughSubject<Void, Never>()
    private let onSelectedSubject = PassthroughSubject<KeyViewModel, Never>()
    private let onDeSelectedSubject = PassthroughSubject<KeyViewModel, Never>()
    private let onSelectSameKeysSubject = PassthroughSubject<KeyViewModel, Never>()

    private var allowSameSelection = true

    override init(ssDevice: SSDevice) {
        super.init(ssDevice: ssDevice)
        loadKeyboardMap()
        loadKeyboardRegionAndKeyCodes()
        prepareKeyViewModel()
        bindInputs()
    }

    private func clearSelection() {
        for keyModel in keyModels {
            keyModel.selected = false
        }
    }

    private func bindInputs() {
        onSelectedSubject.sink { [weak self] keyViewModel in
            self?.selected.insert(keyViewModel)
        }
        .store(in: &cancellables)

        onDeSelectedSubject.sink { [weak self] keyViewModel in
            self?.selected.remove(keyViewModel)
        }
        .store(in: &cancellables)

        onAppearSubject.sink { _ in
            // TODO: Add onAppearSubject stuff
        }
        .store(in: &cancellables)

        onUpdateDeviceSubject.sink { [weak self] _ in
            self?.update()
        }
        .store(in: &cancellables)

        onTouchOutsideSubject.sink { [weak self] _ in
            self?.clearSelection()
        }
        .store(in: &cancellables)
  
        onSelectSameKeysSubject
            .sink { [weak self] keyModel in
                self?.allowSameSelection = false
                self?.handleSameKeySelection(keyModel: keyModel)
                // This delays when same selection is set so that only one key can match with other values
                DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(100))) {
                    self?.allowSameSelection = true
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Functions

    func getKeyModelFromGrid(row: Int, col: Int) -> KeyViewModel? {
        let regionAndKeyCode = keyboardRegionAndKeyCodes[row][col]
        return keyModels.first(where: {
            $0.ssKey.region == regionAndKeyCode.0 &&
            $0.ssKey.keycode == regionAndKeyCode.1
        })
    }

    func calcWidthForKey(width: CGFloat) -> CGFloat {
        return (model == .perKeyGS65 ? 60 : 50) * width
    }

    func calcHeightForKeycode(keycode: UInt8) -> CGFloat {
        return model == .perKeyGS65 ? 60 : keycode == 0x57 || keycode == 0x56 ? 108 : 50
    }

    // Fix Offset for views for perKey large
    func calcOffsetForKeycode(row: Int, keycode: UInt8) -> CGFloat {
        if model == .perKeyGS65 {
            return 0
        }

        if keycode == 0x57 {
            return -58
        } else if keycode == 0x56 {
            return 0
        }

        if row <= 3 {
            return 58
        }

        return 0
    }

    // MARK: - Private Functions

    private func prepareKeyViewModel() {
        // Populate values
        for (rowIndex, row) in keyboardRegionAndKeyCodes.enumerated() {
            for (columnIndex, element) in row.enumerated() {
                let keyboardKeyNames = model == .perKey ? SSPerKeyProperties.perKeyNames : SSPerKeyProperties.perKeyGS65KeyNames
                let key = SSKeyStruct(name: keyboardKeyNames[rowIndex][columnIndex],
                                      region: element.0,
                                      keycode: element.1)
                let keyViewModel = KeyViewModel(ssKey: key)
                keyViewModel.$selected
                    .removeDuplicates()
                    .receive(on: RunLoop.main)
                    .sink(receiveValue: { [weak self] isSelected in
                        guard let `self` = self else { return }
                        if isSelected {
                            if self.mouseMode == 1 && self.allowSameSelection {
                                self.onSelectSameKeysSubject.send(keyViewModel)
                            }
                            self.onSelectedSubject.send(keyViewModel)
                        } else {
                            self.onDeSelectedSubject.send(keyViewModel)
                        }
                    })
                    .store(in: &cancellables)
                keyModels.append(keyViewModel)
            }
        }
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

    private func handleSameKeySelection(keyModel: KeyViewModel) {
        for key in keyModels {
            key.selected = key.ssKey.sameEffect(as: keyModel.ssKey)
        }
    }

    private func update(force: Bool = true) {
        ssDevice.update(data: keyModels.map{ $0.ssKey }, force: force)
    }
}
