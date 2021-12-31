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

    enum MouseMode: String, CaseIterable {
        case single = "cursorarrow"
        case same = "cursorarrow.rays"
        case drag = "rectangle.dashed"
    }

    @Published var finishedLoading = false
    @Published var selectionArray = Set<KeyViewModel>()
    @Published var keyModels = [KeyViewModel]()
    @Published var mouseMode: MouseMode = .single
    @Published var containerDragShapeStart: CGPoint = .zero
    @Published var containerDragShapeEnd: CGSize = .zero

    let keySettingsViewModel = KeySettingsViewModel(keyModels: [])

    private(set) var keyboardMap: [[CGFloat]] = []
    private(set) var keyboardRegionAndKeyCodes: [[(UInt8, UInt8)]] = []

    private let onAppearSubject = PassthroughSubject<Void, Never>()
    private let onUpdateDeviceSubject = PassthroughSubject<Void, Never>()
    private let onTouchOutsideSubject = PassthroughSubject<Void, Never>()
    private let onSelectedSubject = PassthroughSubject<KeyViewModel, Never>()
    private let onDeSelectedSubject = PassthroughSubject<KeyViewModel, Never>()

    private var multipleSelectionChangesActive = false

    override init(ssDevice: SSDevice) {
        super.init(ssDevice: ssDevice)
        loadKeyboardMap()
        loadKeyboardRegionAndKeyCodes()
        prepareKeyViewModel()
        bindInputs()
    }

    private func bindInputs() {
        // This is when the array size changes
        $selectionArray
            .filter({ _ in !self.multipleSelectionChangesActive })
            .sink {[weak self] newValue in
                self?.keySettingsViewModel.selectedKeyModels = newValue
            }
            .store(in: &cancellables)

        // When a view is selected, we get notified
        onSelectedSubject
            .sink { [weak self] keyViewModel in
                guard let `self` = self else { return }
                if self.mouseMode == .same && !self.multipleSelectionChangesActive {
                    self.handleSameKeySelection(keyModel: keyViewModel)
                }

                if !self.selectionArray.contains(keyViewModel) {
                    self.selectionArray.insert(keyViewModel)
                }
            }
            .store(in: &cancellables)

        onDeSelectedSubject
            .sink { [weak self] keyViewModel in
                guard let `self` = self else { return }
                if self.selectionArray.contains(keyViewModel) {
                    self.selectionArray.remove(keyViewModel)
                }
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
    }

    private func clearSelection() {
        if selectionArray.count == 0 {
            return
        }

        multipleSelectionChangesActive = true
        for keyModel in selectionArray {
            if selectionArray.count == 1 {
                // This allows for the "selectionArray"'s publisher to be able to update with the last value
                multipleSelectionChangesActive = false
            }
            keyModel.selected = false
        }
    }

    // MARK: - Private Functions

    private func prepareKeyViewModel() {
        // Populate values
        for (rowIndex, row) in keyboardRegionAndKeyCodes.enumerated() {
            for (columnIndex, element) in row.enumerated() {
                let keyboardKeyNames = model == .perKey ? SSPerKeyProperties.perKeyNames : SSPerKeyProperties.perKeyGS65KeyNames
                let key = SSKey(name: keyboardKeyNames[rowIndex][columnIndex],
                                      region: element.0,
                                      keycode: element.1)
                let keyViewModel = KeyViewModel(ssKey: key, model: ssDevice.model)
                keyViewModel.$selected
                    .removeDuplicates()
                    .sink(receiveValue: { [weak self] isSelected in
                        if isSelected {
                            self?.onSelectedSubject.send(keyViewModel)
                        } else {
                            self?.onDeSelectedSubject.send(keyViewModel)
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

    private func update(force: Bool = true) {
        ssDevice.update(data: keyModels.map{ $0.ssKey }, force: force)
    }

    private func handleSameKeySelection(keyModel: KeyViewModel) {
        multipleSelectionChangesActive = true
        for key in keyModels {
            let same = key.ssKey.sameEffect(as: keyModel.ssKey)
            if key.selected != same {
                key.selected = same
            }
        }
        multipleSelectionChangesActive = false
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
        return (model == .perKeyGS65 ? SSPerKeyProperties.perKeyGS65KeySize : SSPerKeyProperties.perKeyKeySize) * width
    }

    func calcHeightForKeycode(keycode: UInt8) -> CGFloat {
        return model == .perKeyGS65 ? SSPerKeyProperties.perKeyGS65KeySize :
        (keycode == 0x57 || keycode == 0x56 ? 108 : SSPerKeyProperties.perKeyKeySize)
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
}
