//
//  ColorPickerView.swift
//  PrismUI
//
//  Created by Erik Bautista on 1/31/22.
//

import SwiftUI

struct ColorPickerView: View {
    @Binding var color: HSB

    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    ColorBoxView(hsb: $color)
                    ColorHueSlider(hsb: $color)
                        .frame(width: proxy.size.width / 10)
                }
            }
        }
        .frame(width: 275, height: 200, alignment: .center)
        .padding()
    }
}

struct ColorPicker_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerView(color: .constant(.init(hue: 180, saturation: 1.0, brightness: 1.0)))
            .frame(width: 275, height: 200, alignment: .center)
            .padding()
    }
}
