//
//  PopUpColorPicker.swift
//  PrismUI
//
//  Created by Erik Bautista on 2/1/22.
//

import SwiftUI

struct PopUpColorPicker: ViewModifier {
    @Binding var hsb: HSB
    @State var show = false

    func body(content: Content) -> some View {
        content
            .foregroundColor(hsb.color)
            .gesture(
                TapGesture()
                    .onEnded {
                        show.toggle()
                    }
            )
            .popover(isPresented: $show,
                     attachmentAnchor: .point(.bottom),
                     arrowEdge: .bottom) {
                ColorPickerView(color: $hsb)
            }
    }
}
