//
//  PerKeyKeyboardView.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/17/21.
//

import SwiftUI
import PrismKit

struct PerKeyKeyboardView: View {
    @Binding var device: PerKeyKeyboardDevice

    init (device: PerKeyKeyboardDevice) {
        self._device = .constant(device)
    }

    var body: some View {
        Text("\(device.name ) is currently connected")
    }
}
