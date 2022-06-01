//
//  PopUpColorPicker.swift
//  PrismUI
//
//  Created by Erik Bautista on 2/1/22.
//

import SwiftUI

struct PopUpColorPicker: ViewModifier {
    @Binding var color: HSB
    @State var isShowingPopover = false

    func body(content: Content) -> some View {
        content
            .foregroundColor(color.color)
            .onTapGesture {
                isShowingPopover.toggle()
            }
            .popover(
                isPresented: $isShowingPopover,
                attachmentAnchor: .point(.bottom),
                arrowEdge: .bottom
            ) {
                ColorPickerView(color: $color)
            }
    }
}
