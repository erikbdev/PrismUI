//
//  ColourSaturationSlider.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/17/21.
//

import SwiftUI

struct ColourBrightnessSliderView: View {
    @Binding var color: HSB
    @Binding var position: CGFloat
    var range: ClosedRange<CGFloat>

    var leadingOffset: CGFloat = 8
    var trailingOffset: CGFloat = 8
    
    var knobSize: CGSize = CGSize(width: 28, height: 28)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Track
                RoundedRectangle(cornerRadius: geometry.size.width / 2)
                    .fill(
                        LinearGradient(colors: [Color.black, Color(hue: color.hue / 360.0,
                                                                   saturation: color.saturation,
                                                                   brightness: 1)],
                                       startPoint: .top,
                                       endPoint: .bottom))
                ThumbView(color: color.rgb)
                    .frame(width: geometry.size.width,
                           height: geometry.size.width)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * color.brightness)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged({ value in
                                var dragOffsetHeight = value.location.y / geometry.size.height
                                if dragOffsetHeight < 0.0001 {
                                    dragOffsetHeight = 0.0001
                                } else if dragOffsetHeight > 1.0 {
                                    dragOffsetHeight = 1.0
                                }
                                color = HSB(hue: color.hue,
                                            saturation: color.saturation,
                                            brightness: dragOffsetHeight)
                            })
                    )
            }
            .rotationEffect(Angle(degrees: 180))
            .shadow(radius: 20)
        }
    }
}

struct ColourBrightnessSliderView_Previews: PreviewProvider {
    static var previews: some View {
        ColourBrightnessSliderView(color: .constant(HSB(hue: 0, saturation: 1, brightness: 1)), position: .constant(0), range: 0.0001...1)
            .frame(width: 40, height: 500)
    }
}
