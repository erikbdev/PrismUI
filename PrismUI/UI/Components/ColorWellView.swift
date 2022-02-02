//
//  ColorWellView.swift
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
            .onTapGesture(perform: {
                showingColorPicker = true
            })
            .popover(isPresented: $showingColorPicker,
                     attachmentAnchor: .point(.bottom),
                     arrowEdge: .bottom) {
                ColorPickerView(color: $hsb)
            }
    }
}

//struct ColorWellView: View {
//    @Binding var hsb: HSB
//    @State var showingColorPicker = false
//
//    var body: some View {
//        RoundedRectangle(cornerRadius: 8)
//            .foregroundColor(hsb.color)
//            .onTapGesture {
//                showingColorPicker = true
//            }
//            .popover(isPresented: $showingColorPicker,attachmentAnchor: .point(.bottom), arrowEdge: .bottom) {
//                ColorPickerView(color: $hsb)
//            }
//    }
//}
//
//struct ColorWellView_Previews: PreviewProvider {
//    static var previews: some View {
//        ColorWellView(hsb: .constant(.init(hue: 0, saturation: 1.0, brightness: 1.0)))
//    }
//}
