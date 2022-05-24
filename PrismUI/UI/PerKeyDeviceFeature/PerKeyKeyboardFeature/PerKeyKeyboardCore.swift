//
//  PerKeyKeyboardCore.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/21/22.
//

import Foundation
import ComposableArchitecture
import PrismClient

struct PerKeyKeyboardCore {
    struct State: Equatable {
        var keys: IdentifiedArrayOf<KeyCore.State> = []
        var model: Models = .unknown
        var keysLoaded = false
    }

    enum Action: Equatable {
        case onAppear
        case loadKeys
        case key(id: KeyCore.State.ID, action: KeyCore.Action)
    }

    struct Environment {}

    static let reducer: Reducer<PerKeyKeyboardCore.State, PerKeyKeyboardCore.Action, PerKeyKeyboardCore.Environment> = .combine(
        KeyCore.reducer.forEach(
            state: \.keys,
            action: /PerKeyKeyboardCore.Action.key(id:action:),
            environment: { _ in .init() }
        ),

        .init { state, action, environment in
            switch action {
            case .onAppear:
                // Call load keys action and notify parent view
                return .init(value: .loadKeys)
            case .loadKeys:
                // Load keys based on model
                let keyCodes: [[(UInt8, UInt8)]] = PerKeyProperties.getKeyboardCodes(for: state.model)
                let keyNames: [[String]] = state.model == .perKey ? PerKeyProperties.perKeyNames : PerKeyProperties.perKeyGS65KeyNames

                var keysStore: IdentifiedArrayOf<KeyCore.State> = []

                for i in keyCodes.enumerated() {
                    let row = i.offset
        
                    for j in i.element.enumerated() {
                        let column = j.offset
        
                        let keyName = keyNames[row][column]
                        let keyRegion = j.element.0
                        let keyCode = j.element.1
                        let ssKey = Key(name: keyName, region: keyRegion, keycode: keyCode)
                        keysStore.append(.init(key: ssKey))
                    }
                }
                state.keys = keysStore
                state.keysLoaded = true
            case .key(id: let id, action: .toggleSelection):
                break
            }
            return .none
        }
    )
}
