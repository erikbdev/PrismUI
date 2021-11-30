//
//  PerKeyKeyboardView.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/17/21.
//

import SwiftUI
import PrismKit

struct PerKeyKeyboardView: View {
    @Binding var device: PrismDevice

    init (device: PrismDevice) {
        self._device = .constant(device)
    }

    var body: some View {
        if device.ssDevice.model == .perKeyGS65 {
            
        }
        Text("\(device.name) is currently connected")
    }
}
