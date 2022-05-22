//
//  KeyCore.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/22/22.
//

import Foundation
import ComposableArchitecture
import PrismClient

struct KeyCore {
    struct State: Equatable, Identifiable {
        var id: UInt16 {
            key.id
        }
        
        var key: Key
        var selected = false
    }

    enum Action: Equatable {
        case toggleSelected
    }

    struct Environment {  }

    static let reducer = Reducer<KeyCore.State, KeyCore.Action, KeyCore.Environment> { state, action, environment in
        return .none
    }
}

//final class KeyViewModel: BaseViewModel, UniDirectionalDataFlowType {
//    typealias InputType = Input
//
//    enum Input {
//        case onAppear
//    }
//
//    func apply(_ input: Input) {
//        switch input {
//        case .onAppear:
//            onAppearSubject.send()
//        }
//    }
//
//    private let onAppearSubject = PassthroughSubject<Void, Never>()
//
//    @Published var ssKey: SSKey
//    @Published var selected = false
//    @Published var gradientProgress: CGFloat = 0
//
//    private var animationCancellable: Cancellable?
//    private var startTime: Double = 0
//    private let model: SSModels
//
//    var mode: SSKey.KeyModes {
//        return ssKey.mode
//    }
//
//    init(ssKey: SSKey, model: SSModels) {
//        self.ssKey = ssKey
//        self.model = model
//        super.init()
//        bindInputs()
//    }
//
//    private func bindInputs() {
//        onAppearSubject
//            .sink { _ in }
//            .store(in: &cancellables)
//
//        $ssKey
//            .removeDuplicates()
//            .sink { [weak self] key in
//                self?.animationCancellable?.cancel()
//                if let effect = key.effect {
//                    self?.handleEffectsAnimation(mode: key.mode,effect: effect)
//                }
//            }
//            .store(in: &cancellables)
//    }
//
//    private func handleEffectsAnimation(mode: SSKey.SSKeyModes, effect: KeyEffect) {
//        if mode == .breathing || mode == .colorShift && !effect.waveActive {
//            gradientAnimation(effect: effect)
//        } else {
//            customWaveAnimation(effect: effect)
//        }
//
//        animationCancellable = DisplayLink.shared
//            .sink(receiveValue: { [weak self] frame in
//                self?.handleFrameChanged(frame: frame, effect: effect)
//            })
//    }
//
//    func gradientAnimation(effect: SSKeyEffect) {
//        gradientProgress = 0.0
//        startTime = -1
//    }
//
//    func customWaveAnimation(effect: SSKeyEffect) {
//        let keyboardRegionAndKeycodes = model == .perKeyGS65 ? PerKeyProperties.perKeyGS65RegionKeyCodes : SSPerKeyProperties.perKeyRegionKeyCodes
//        let keyboardMap = model == .perKeyGS65 ? SSPerKeyProperties.perKeyGS65KeyMap : SSPerKeyProperties.perKeyMap
//        let maxColumnCount = CGFloat(keyboardMap.first?.count ?? 0)
//        let maxRowCount = CGFloat(keyboardMap.count)
//
//        let rowIndex = keyboardRegionAndKeycodes.firstIndex { column in
//            column.contains { (region, keycode) in
//                ssKey.region == region && ssKey.keycode == keycode
//            }
//        } ?? 0
//
//        let columnIndex = keyboardRegionAndKeycodes[rowIndex].firstIndex { region, keycode in
//            ssKey.region == region && ssKey.keycode == keycode
//        } ?? 0
//
//        let keyXPosition = (keyboardMap[rowIndex].enumerated()
//            .filter { $0.offset < columnIndex }
//            .map({ $0.element })
//            .reduce(0, { $0 + $1 })
//            + keyboardMap[rowIndex][columnIndex] / 2) // We need to add half of the key width so it can be centered
//            / CGFloat(maxColumnCount)
//
//        let keyYPosition = (CGFloat(rowIndex) + 0.5) / CGFloat(maxRowCount)
//
//        // Calculating effect
//        let origin = effect.origin
//        let pulseWidth = (CGFloat(effect.pulse) / 100.0)
//
//        var directionDelta = 0.0
//
//        if effect.direction == .xy {
//            let maxRadius = 1.0
//            let distanceX = abs(origin.x - keyXPosition)
//            let distanceY = abs(origin.y - keyYPosition)
//            let diagDistance = sqrt(pow(distanceX, 2) + pow(distanceY, 2)) / maxRadius
//            directionDelta = diagDistance
//        } else {
//            var xDelta = keyXPosition - origin.x
//            var yDelta = keyYPosition - origin.y
//            if xDelta < 0 { xDelta += 1 }; if yDelta < 0 { yDelta += 1 }
//            directionDelta = (effect.direction == .x ? xDelta : yDelta)
//        }
//        directionDelta /= pulseWidth
//
//        if directionDelta > 1.0 { directionDelta -= floor(directionDelta) }
//
//        gradientProgress = directionDelta
//        startTime = -1
//    }
//
//    private func handleFrameChanged(frame: DisplayLink.Frame, effect: SSKeyEffect) {
//        if startTime == -1 {
//            startTime = frame.timestamp
//        } else {
//            let timeInterval = frame.timestamp - startTime
//            if timeInterval < 1/30 { return } // Reduce to 1/30 so cpu doesn't get overwhelmed
//            let calc = CGFloat(effect.duration) / 1000.0
//            let mod = timeInterval / calc
//            var newProgress = gradientProgress
//
//            if effect.control == .inward {
//                newProgress += mod
//            } else {
//                newProgress -= mod
//            }
//
//            if newProgress > 1.0 || newProgress < 0 {
//                newProgress -= floor(newProgress)
//            }
//            gradientProgress = newProgress
//            startTime = frame.timestamp
//        }
//    }
//
//    func getColor() -> RGB {
//        if let effect = ssKey.effect {
//            let transitions = effect.transitions
//            return RGB.getColorFromTransition(with: gradientProgress,
//                                              transitions: transitions.map({ ColorSelector(rgb: $0.color, position: $0.position) }))
//        } else {
//            return ssKey.main
//        }
//    }
//}
//
//extension KeyViewModel: Hashable {
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(ssKey.region)
//        hasher.combine(ssKey.keycode)
//    }
//
//    static func == (lhs: KeyViewModel, rhs: KeyViewModel) -> Bool {
//        lhs.ssKey.region == rhs.ssKey.region &&
//        lhs.ssKey.keycode == rhs.ssKey.keycode
//    }
//}
