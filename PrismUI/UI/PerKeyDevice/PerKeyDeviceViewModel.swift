//
//  PerKeyDeviceViewModel.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/1/21.
//

import Combine
import PrismKit
import Ricemill
import CoreGraphics

final class PerKeyDeviceViewModel: Machine<PerKeyDeviceViewModel> {
    typealias Output = Store

    final class Input: BindableInputType {
        let appearedTrigger = PassthroughSubject<Void, Never>()
        let touchedOutsideTriger = PassthroughSubject<Void, Never>()
        let updateDeviceTrigger = PassthroughSubject<Void, Never>()
        let draggedOutsideTrigger = PassthroughSubject<(start: CGPoint, current: CGPoint), Never>()
        let selectionTrigger = PassthroughSubject<IndexPath, Never>()

        @Published var mouseMode: MouseMode = .single
    }

    final class Store: StoredOutputType {
        var keySettingsViewModel: KeySettingsViewModel = .make(extra: .init())
        @Published var name: String = ""
        @Published var model: SSModels = .unknown
        @Published var keys: [[SSKey]] = []
        @Published var selected: Set<IndexPath> = .init()
    }

    struct Extra: ExtraType {
        let device: SSDevice
    }

    static func polish(input: Publishing<Input>, store: Store, extra: Extra) -> Polished<Output> {
        var cancellables: [AnyCancellable] = []

        let appearedTrigger = input.appearedTrigger
            .eraseToAnyPublisher()
            .share()

        appearedTrigger
            .flatMap { _ in Just(extra.device.name) }
            .assign(to: \.name, on: store)
            .store(in: &cancellables)

        appearedTrigger
            .flatMap { _ in Just(extra.device.model) }
            .assign(to: \.model, on: store)
            .store(in: &cancellables)

        appearedTrigger
            .flatMap { _ in Just(extra.device.model) }
            .map { PerKeyDeviceViewModel.makeKeys(for: $0) }
            .assign(to: \.keys, on: store)
            .store(in: &cancellables)

        input.selectionTrigger
            .eraseToAnyPublisher()
            .sink { index in
                if input.mouseMode == .same {
                    var selection = Set<IndexPath>()
                    let keyMatch = store.keys[index.section][index.item]
                    for row in store.keys.indices {
                        for column in store.keys[row].indices {
                            let key = store.keys[row][column]
                            let same = keyMatch.sameEffect(as: key)
                            if same {
                                selection.insert(.init(item: column, section: row))
                            }
                        }
                    }
                    store.selected = selection
                } else {
                    if store.selected.contains(index) {
                        store.selected.remove(index)
                    } else {
                        store.selected.insert(index)
                    }
                }
            }
            .store(in: &cancellables)

        input.touchedOutsideTriger
            .eraseToAnyPublisher()
            .sink(receiveValue: { store.selected.removeAll() })
            .store(in: &cancellables)

//        store.$selected
//            .eraseToAnyPublisher()
//            .removeDuplicates()
//            .map({ $0.count })
//            .sink { print($0) }
//            .store(in: &cancellables)

        return Polished(cancellables: cancellables)
    }

    static func make(extra: Extra) -> PerKeyDeviceViewModel {
        PerKeyDeviceViewModel(input: Input(), store: Store(), extra: extra)
    }
}

// MARK: - Mouse Modes

extension PerKeyDeviceViewModel {
    enum MouseMode: String, CaseIterable {
        case single = "cursorarrow"
        case same = "cursorarrow.rays"
        case rectangle = "rectangle.dashed"
    }
}

extension PerKeyDeviceViewModel {
    private func handleSameKeySelection() {
        
    }
}

// MARK: - Generating keys and layouts

extension PerKeyDeviceViewModel {
    private static func makeKeys(for model: SSModels) -> [[SSKey]] {
        let keyCodes: [[(UInt8, UInt8)]] = SSPerKeyProperties.getKeyboardCodes(for: model)
        let keyNames: [[String]] = model == .perKey ? SSPerKeyProperties.perKeyNames : SSPerKeyProperties.perKeyGS65KeyNames

        var keyViewModels: [[SSKey]] = []

        for i in keyCodes.enumerated() {
            let row = i.offset
            keyViewModels.append([])

            for j in i.element.enumerated() {
                let column = j.offset

                let keyName = keyNames[row][column]
                let keyRegion = j.element.0
                let keyCode = j.element.1
                let ssKey = SSKey(name: keyName, region: keyRegion, keycode: keyCode)
                keyViewModels[row].append(ssKey)
            }
        }

        return keyViewModels
    }
}

//    // MARK: Input
//    enum Input {
//        case onAppear
//        case onTouchOutside
//        case onUpdateDevice
//        case onDragOutside(start: CGPoint, currentPoint: CGPoint)
//    }
//
//    func apply(_ input: Input) {
//        switch input {
//        case .onAppear:
//            onAppearSubject.send()
//        case .onUpdateDevice:
//            onUpdateDeviceSubject.send()
//        case .onTouchOutside:
//            onTouchOutsideSubject.send()
//        case .onDragOutside(start: let start, currentPoint: let currentPoint):
//            onDragOutsideSubject.send((start, currentPoint))
//        }
//    }
//
//    enum MouseMode: String, CaseIterable {
//        case single = "cursorarrow"
//        case same = "cursorarrow.rays"
//        case rectangle = "rectangle.dashed"
//    }
//
//    @Published var mouseMode: MouseMode = .single
//    @Published var dragSelectionRect = CGRect.zero
//
//    lazy var keySettingsViewModel = KeySettingsViewModel(keyModels: []) { [weak self ] in
//        self?.apply(.onUpdateDevice)
//    }
//
//    private(set) var keyboardMap: [[CGFloat]]
//
//    private let onAppearSubject = PassthroughSubject<Void, Never>()
//    private let onUpdateDeviceSubject = PassthroughSubject<Void, Never>()
//    private let onTouchOutsideSubject = PassthroughSubject<Void, Never>()
//    private let onSelectedSubject = PassthroughSubject<KeyViewModel, Never>()
//    private let onDeSelectedSubject = PassthroughSubject<KeyViewModel, Never>()
//    private let onDragOutsideSubject = PassthroughSubject<(CGPoint, CGPoint), Never>()
//
//    private var selectionArray = Set<KeyViewModel>() {
//        didSet {
//            updateSelectionChanges()
//        }
//    }
//    private var keyModels = [KeyViewModel]()
//    private var multipleSelectionChangesActive = false
//
//    override init(ssDevice: SSDevice) {
//        self.keyboardMap = SSPerKeyProperties.getKeyboardMap(for: ssDevice.model)
//        super.init(ssDevice: ssDevice)
//        prepareKeyViewModel()
//        bindInputs()
//    }
//
//    private func bindInputs() {
//        // When a view is selected, we get notified
//        onSelectedSubject
//            .sink { [weak self] keyViewModel in
//                guard let `self` = self else { return }
//                if self.mouseMode == .same && !self.multipleSelectionChangesActive {
//                    self.handleSameKeySelection(keyModel: keyViewModel)
//                }
//
//                if !self.selectionArray.contains(keyViewModel) {
//                    self.selectionArray.insert(keyViewModel)
//                }
//            }
//            .store(in: &cancellables)
//
//        onDeSelectedSubject
//            .sink { [weak self] keyViewModel in
//                guard let `self` = self else { return }
//                if self.selectionArray.contains(keyViewModel) {
//                    self.selectionArray.remove(keyViewModel)
//                }
//            }
//            .store(in: &cancellables)
//
//        onAppearSubject.sink { _ in
//            // TODO: Add onAppearSubject stuff
//        }
//        .store(in: &cancellables)
//
//        onUpdateDeviceSubject
//            .debounce(for: .milliseconds(150), scheduler: DispatchQueue.global(qos: .default))
//            .sink { [weak self] _ in
//                self?.update()
//        }
//        .store(in: &cancellables)
//
//        onTouchOutsideSubject.sink { [weak self] _ in
//            self?.clearSelection()
//        }
//        .store(in: &cancellables)
//
//        onDragOutsideSubject
//            .sink { [weak self] (start, current) in
//                guard self?.mouseMode == .rectangle else { return }
//                let width = abs(current.x - start.x)
//                let height = abs(current.y - start.y)
//
//                var originX = start.x
//                if current.x > start.x {
//                    originX += width / 2
//                } else {
//                    originX -= width / 2
//                }
//
//                var originY = start.y
//                if current.y > start.y {
//                    originY += height / 2
//                } else {
//                    originY -= height / 2
//                }
//
//                self?.dragSelectionRect = CGRect(origin: CGPoint(x: originX, y: originY),
//                                                size: CGSize(width: width, height: height))
//            }
//            .store(in: &cancellables)
//    }
//    // MARK: - Private Functions
//
//    private func update(force: Bool = true) {
//        ssDevice.update(data: keyModels.map{ $0.ssKey }, force: force)
//    }
//
//    private func handleSameKeySelection(keyModel: KeyViewModel) {
//        multipleSelectionChangesActive = true
//        for key in keyModels {
//            let same = key.ssKey.sameEffect(as: keyModel.ssKey)
//            if key.selected != same {
//                key.selected = same
//            }
//        }
//        multipleSelectionChangesActive = false
//    }
