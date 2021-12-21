//
//  ColourSaturationSlider.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/17/21.
//

import SwiftUI

struct ColourBrightnessSliderView: View {
    @Binding var color: HSV
    @Binding var position: CGFloat
    var range: ClosedRange<CGFloat>
    @State var lastOffset: CGFloat = 0
    @State var isTouchingKnob = false

    var leadingOffset: CGFloat = 8
    var trailingOffset: CGFloat = 8
    
    var knobSize: CGSize = CGSize(width: 28, height: 28)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Track
                RoundedRectangle(cornerRadius: geometry.size.height / 2)
                    .fill(
                        LinearGradient(colors: [Color.black, Color(hue: color.hue / 360.0,
                                                                   saturation: color.saturation,
                                                                   brightness: 1)],
                                       startPoint: .leading,
                                       endPoint: .trailing))
                Circle()
                    .fill(Color(hue: color.hue / 360.0,
                                saturation: color.saturation,
                                brightness: color.brightness))
                    .frame(width: geometry.size.height,
                           height: geometry.size.height)
                    .overlay(
                        Circle()
                            .strokeBorder(Color(red: 1, green: 1, blue: 1), lineWidth: 2)
                    )
                    .position(x: geometry.size.width * color.brightness, y: geometry.size.height / 2)
                    .shadow(radius: 8, x: 0, y: 2)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged({ value in
                                var dragOffsetWidth = value.location.x / geometry.size.width
                                if dragOffsetWidth < 0.0001 {
                                    dragOffsetWidth = 0.0001
                                } else if dragOffsetWidth > 1.0 {
                                    dragOffsetWidth = 1.0
                                }
                                color = HSV(hue: color.hue,
                                            saturation: color.saturation,
                                            brightness: dragOffsetWidth)
                            })
                    )
            }
            .shadow(radius: 20)
        }
    }
}

struct ColourBrightnessSliderView_Previews: PreviewProvider {
    static var previews: some View {
        ColourBrightnessSliderView(color: .constant(HSV(hue: 0, saturation: 1, brightness: 1)), position: .constant(0), range: 0.0001...1)
            .frame(width: 500, height: 40)
    }
}
