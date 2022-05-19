//
//  PerKeyDeviceViewModel.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/1/21.
//

import Combine
import PrismClient
import Ricemill

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
        @Published var name: String = ""
        @Published var model: Models = .unknown
        @Published var keys: [[Key]] = []
        @Published var selected: Set<IndexPath> = .init()

        fileprivate let updateCallback = PassthroughSubject<KeyEffects, Never>()

        lazy var keySettingsViewModel: KeySettingsViewModel = .make(
            extra: .init(
                updateCallback: { [unowned self] in updateCallback.send($0) }
            )
        )
    }

    struct Extra: ExtraType {
        let device: Device
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
            .filter { !store.selected.isEmpty }
            .sink { store.selected.removeAll() }
            .store(in: &cancellables)

        store.$selected
            .map({ $0.map({ index in store.keys[index.section][index.item] }) })
            .removeDuplicates()
            .sink { store.keySettingsViewModel.input.selectedKeys.send($0) }
            .store(in: &cancellables)

        store.updateCallback
            .sink { effect in
                store.selected.forEach { indexPath in
                    var key = store.keys[indexPath.section][indexPath.item]

                    switch effect {
                    case .steady(color: let color):
                        key.mode = .steady
                        key.main = color.rgb
                    case .colorShift(colorSelectors: let colorSelectors,
                                     speed: let speed,
                                     waveActive: let waveActive,
                                     waveDirection: let waveDirection,
                                     waveControl: let waveControl,
                                     pulse: let pulse,
                                     origin: let origin):

                        let transitions = colorSelectors.compactMap({ KeyEffect.SSPerKeyTransition(color: $0.rgb, position: $0.position) })
                            .sorted(by: { $0.position < $1.position })

                        guard transitions.count > 0 else { return }

                        var effect = KeyEffect(id: 0, transitions: transitions)
                        effect.start = transitions[0].color
                        effect.duration = UInt16(speed)
                        effect.waveActive = waveActive
                        effect.direction = waveDirection
                        effect.control = waveControl
                        effect.origin = origin
                        effect.pulse = UInt16(pulse)

                        key.mode = .colorShift
                        key.effect = effect
                        key.main = effect.start

                    case .breathing(colorSelectors: let colorSelectors, speed: let speed):
                        let baseTransitions = colorSelectors.compactMap({ KeyEffect.SSPerKeyTransition(color: $0.rgb, position: $0.position) })
                            .sorted(by: { $0.position < $1.position })

                        guard baseTransitions.count > 0 else {
                            print("Cannot use latest transition from breathing mode because there are no transitions.")
                            return
                        }

                        var transitions: [KeyEffect.SSPerKeyTransition] = []

                        // We add the transitions from baseTransition and also add the half values between
                        // each transition to have the breathing effect.
                        for inx in baseTransitions.indices {
                            let firstSelector = baseTransitions[inx]
                            transitions.append(firstSelector)

                            var halfDistance: CGFloat
                            if (inx + 1) < baseTransitions.count {
                                let secondSelector = baseTransitions[inx + 1]
                                halfDistance = (secondSelector.position + firstSelector.position) / 2
                            } else {
                                halfDistance = (1 + firstSelector.position) / 2
                            }

                            transitions.append(KeyEffect.SSPerKeyTransition(color: RGB(), position: halfDistance))
                        }

                        var effect = KeyEffect(id: 0,
                                                 transitions: transitions)

                        effect.start = transitions[0].color
                        effect.duration = UInt16(speed)

                        key.mode = .breathing
                        key.effect = effect
                        key.main = effect.start
                    case .reactive(activeColor: let activeColor, restColor: let restColor, speed: let speed):
                        key.mode = .reactive
                        key.main = restColor.rgb
                        key.active = activeColor.rgb
                        key.duration = UInt16(speed)
                    case .disabled:
                        key.mode = .disabled
                    }

                    store.keys[indexPath.section][indexPath.item] = key
                }
            }
            .store(in: &cancellables)

        return .init(cancellables: cancellables)
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

// MARK: - Generating keys and layouts

extension PerKeyDeviceViewModel {
    private static func makeKeys(for model: Models) -> [[Key]] {
        let keyCodes: [[(UInt8, UInt8)]] = PerKeyProperties.getKeyboardCodes(for: model)
        let keyNames: [[String]] = model == .perKey ? PerKeyProperties.perKeyNames : PerKeyProperties.perKeyGS65KeyNames

        var keyViewModels: [[Key]] = []

        for i in keyCodes.enumerated() {
            let row = i.offset
            keyViewModels.append([])

            for j in i.element.enumerated() {
                let column = j.offset

                let keyName = keyNames[row][column]
                let keyRegion = j.element.0
                let keyCode = j.element.1
                let ssKey = Key(name: keyName, region: keyRegion, keycode: keyCode)
                keyViewModels[row].append(ssKey)
            }
        }

        return keyViewModels
    }
}
