//
//  PerKeyDeviceViewModel.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/1/21.
//

import Combine
import PrismKit

final class PerKeyDeviceViewModel: DeviceViewModel, UniDirectionalDataFlowType {

    // MARK: Input
    enum Input {
        case onAppear
        case onTouchOutside
        case onUpdateDevice
        case onDragOutside(start: CGPoint, currentPoint: CGPoint)
    }

    func apply(_ input: Input) {
        switch input {
        case .onAppear:
            onAppearSubject.send()
        case .onUpdateDevice:
            onUpdateDeviceSubject.send()
        case .onTouchOutside:
            onTouchOutsideSubject.send()
        case .onDragOutside(start: let start, currentPoint: let currentPoint):
            onDragOutsideSubject.send((start, currentPoint))
        }
    }

    enum MouseMode: String, CaseIterable {
        case single = "cursorarrow"
        case same = "cursorarrow.rays"
        case rectangle = "rectangle.dashed"
    }

    @Published var mouseMode: MouseMode = .single
    @Published var dragSelectionRect = CGRect.zero

    lazy var keySettingsViewModel = KeySettingsViewModel(keyModels: []) { [weak self ] in
        self?.apply(.onUpdateDevice)
    }

    private(set) var keyboardMap: [[CGFloat]]

    private let onAppearSubject = PassthroughSubject<Void, Never>()
    private let onUpdateDeviceSubject = PassthroughSubject<Void, Never>()
    private let onTouchOutsideSubject = PassthroughSubject<Void, Never>()
    private let onSelectedSubject = PassthroughSubject<KeyViewModel, Never>()
    private let onDeSelectedSubject = PassthroughSubject<KeyViewModel, Never>()
    private let onDragOutsideSubject = PassthroughSubject<(CGPoint, CGPoint), Never>()

    private var selectionArray = Set<KeyViewModel>() {
        didSet {
            updateSelectionChanges()
        }
    }
    private var keyModels = [KeyViewModel]()
    private var multipleSelectionChangesActive = false

    override init(ssDevice: SSDevice) {
        self.keyboardMap = SSPerKeyProperties.getKeyboardMap(for: ssDevice.model)
        super.init(ssDevice: ssDevice)
        prepareKeyViewModel()
        bindInputs()
    }

    private func bindInputs() {
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

        onUpdateDeviceSubject
            .debounce(for: .milliseconds(150), scheduler: DispatchQueue.global(qos: .default))
            .sink { [weak self] _ in
                self?.update()
        }
        .store(in: &cancellables)

        onTouchOutsideSubject.sink { [weak self] _ in
            self?.clearSelection()
        }
        .store(in: &cancellables)

        onDragOutsideSubject
            .sink { [weak self] (start, current) in
                guard self?.mouseMode == .rectangle else { return }
                let width = abs(current.x - start.x)
                let height = abs(current.y - start.y)

                var originX = start.x
                if current.x > start.x {
                    originX += width / 2
                } else {
                    originX -= width / 2
                }

                var originY = start.y
                if current.y > start.y {
                    originY += height / 2
                } else {
                    originY -= height / 2
                }

                self?.dragSelectionRect = CGRect(origin: CGPoint(x: originX, y: originY),
                                                size: CGSize(width: width, height: height))
            }
            .store(in: &cancellables)
    }

    // This is when the array size changes

    private func updateSelectionChanges() {
        guard !multipleSelectionChangesActive else { return }
        keySettingsViewModel.selectedKeyModels = selectionArray
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

    private func update(force: Bool = true) {
        ssDevice.update(data: keyModels.map{ $0.ssKey }, force: force)
    }

    private func prepareKeyViewModel() {
        let keyboardRegionAndKeyCodes = PerKeyDeviceViewModel.loadKeyboardRegionAndKeyCodes(for: ssDevice.model)

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

    private func loadKeyboardMap(ssDevice: SSDevice) -> [[CGFloat]] {
        switch (ssDevice.model) {
        case .perKey:
            return SSPerKeyProperties.perKeyMap
        case .perKeyGS65:
            return SSPerKeyProperties.perKeyGS65KeyMap
        default:
            return []
        }
    }

    private static func loadKeyboardRegionAndKeyCodes(for model: SSModels) -> [[(UInt8, UInt8)]] {
        switch (model) {
        case .perKey:
            return SSPerKeyProperties.perKeyRegionKeyCodes
        case .perKeyGS65:
            return SSPerKeyProperties.perKeyGS65RegionKeyCodes
        default:
            return []
        }
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
        let keyboardRegionAndKeyCodes = PerKeyDeviceViewModel.loadKeyboardRegionAndKeyCodes(for: ssDevice.model)
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
