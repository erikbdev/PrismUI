//
//  ColourPickerView.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/17/21.
//

import SwiftUI

struct ColourPickerView: View {
    @Binding var color: HSB
    @State var brightness: CGFloat = 1

    private let thumbSize: CGFloat = 26
    private let spacing: CGFloat = 12

    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: spacing) {
                ColourWheelView(color: $color)
                ColourBrightnessSliderView(color: $color, position: $brightness, range: 0.001...1)
                    .frame(width: thumbSize, height: minSize(geometry) - thumbSize)
            }
        }
    }

    private func minSize(_ geometry: GeometryProxy) -> CGFloat {
        return min(geometry.size.width, geometry.size.height)
    }
}

struct ColourPicker_Previews: PreviewProvider {
    static var previews: some View {
        ColourPickerView(color: .constant(HSB(hue: 0, saturation: 1, brightness: 1)))
            .frame(width: 300, height: 400)
    }
}
