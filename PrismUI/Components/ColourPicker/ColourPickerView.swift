//
//  ColourPickerView.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/17/21.
//

import SwiftUI

struct ColourPickerView: View {
    @Binding var color: HSV
    @State var brightness: CGFloat = 1

    var body: some View {
        VStack {
            ColourWheelView(color: $color)
            ColourBrightnessSliderView(color: $color, position: $brightness, range: 0.001...1)
                .frame(height: 26)
                .padding([.leading, .trailing])
        }
        .padding([.top, .bottom])
    }
}

struct ColourPicker_Previews: PreviewProvider {
    static var previews: some View {
        ColourPickerView(color: .constant(HSV(hue: 0, saturation: 1, brightness: 1)))
    }
}
