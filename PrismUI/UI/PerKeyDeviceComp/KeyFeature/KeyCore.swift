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
