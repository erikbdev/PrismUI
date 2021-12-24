//
//  KeyViewModel.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/1/21.
//

import PrismKit
import Combine

final class KeyViewModel: BaseViewModel {
    @Published var ssKey: SSKeyStruct
    @Published var selected = false

    init(ssKey: SSKeyStruct) {
        self.ssKey = ssKey
    }
}

extension KeyViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ssKey.region)
        hasher.combine(ssKey.keycode)
    }

    static func == (lhs: KeyViewModel, rhs: KeyViewModel) -> Bool {
        lhs.ssKey.region == rhs.ssKey.region &&
        lhs.ssKey.keycode == rhs.ssKey.keycode
    }
}
