//
//  PopUpColorPicker.swift
//  PrismUI
//
//  Created by Erik Bautista on 2/1/22.
//

import SwiftUI

struct PopUpColorPicker: ViewModifier {
    @State var showingColorPicker = false
    @Binding var hsb: HSB

    func body(content: Content) -> some View {
        content
            .foregroundColor(hsb.color)
            .gesture(
                TapGesture()
                    .onEnded({
                        showingColorPicker.toggle()
                    })
            )
            .popover(isPresented: $showingColorPicker,
                     attachmentAnchor: .point(.bottom),
                     arrowEdge: .bottom) {
                ColorPickerView(color: $hsb)
            }
    }
}
