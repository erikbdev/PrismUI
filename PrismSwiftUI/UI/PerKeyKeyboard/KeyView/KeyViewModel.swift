//
//  KeyViewModel.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/1/21.
//

import PrismKit
import Combine

final class KeyViewModel: BaseViewModel {
    var ssKey: SSKey
    @Published var selected = false

    init(ssKey: SSKey) {
        self.ssKey = ssKey
    }
}
