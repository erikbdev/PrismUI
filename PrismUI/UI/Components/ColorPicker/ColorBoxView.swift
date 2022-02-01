//
//  ColorBoxView.swift
//  PrismUI
//
//  Created by Erik Bautista on 1/31/22.
//

import SwiftUI
import Then

struct ColorBoxView: View {
    @Binding var hsb: HSB

    private var correctedColor: HSB {
        var copy = hsb
        copy.saturation = 1.0
        copy.brightness = 1.0
        return copy
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ZStack {
                    Rectangle()
                        .fill(correctedColor.color)
                    Rectangle()
                        .fill(LinearGradient(colors: [.white, .clear], startPoint: .leading, endPoint: .trailing))
                    Rectangle()
                        .fill(LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top))
                }
                .cornerRadius(proxy.size.width / 16)

                Circle()
                    .strokeBorder(Color.white, lineWidth: 2)
                    .background(Circle().foregroundColor(hsb.color))
                    .frame(width: proxy.size.width / 8, height: proxy.size.width / 8)
                    .position(getOffset(for: proxy.size))
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                var saturation = value.location.x / proxy.size.width
                                var brightness = 1 - (value.location.y / proxy.size.height)

                                saturation = max(0, min(1.0, saturation))
                                brightness = max(0, min(1.0, brightness))

                                var copy = hsb
                                copy.saturation = saturation
                                copy.brightness = brightness
                                hsb = copy
                            })
                    )
            }
        }
    }

    private func getOffset(for size: CGSize) -> CGPoint {
        let saturation = hsb.saturation
        let brightness = hsb.brightness

        let width = saturation * size.width
        let height = (1 - brightness) * size.height
        return CGPoint(x: width, y: height)
    }
}

struct ColorBoxView_Previews: PreviewProvider {
    static var previews: some View {
        ColorBoxView(hsb: .constant(.init(hue: 0, saturation: 1.0, brightness: 1.0)))
            .frame(width: 100, height: 75)
    }
}
