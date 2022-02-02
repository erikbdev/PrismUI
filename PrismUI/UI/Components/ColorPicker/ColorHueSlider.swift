//
//  ColorHueSlider.swift
//  PrismUI
//
//  Created by Erik Bautista on 1/31/22.
//

import SwiftUI

struct ColorHueSlider: View {
    @Binding var hsb: HSB

    private var correctedColor: HSB {
        return HSB(hue: hsb.hue, saturation: 1.0, brightness: 1.0)
    }

    private var backgroundColors: [Color] {
        let hueValues = 0..<360
        let hueArray = hueValues.map({ HSB(hue: CGFloat($0), saturation: 1.0, brightness: 1.0) })

        return hueArray.map({ $0.color })
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                RoundedRectangle(cornerRadius:  proxy.size.width / 2)
                    .fill(
                        LinearGradient(colors: backgroundColors,
                                       startPoint: .top,
                                       endPoint: .bottom)
                    )
                Circle()
                    .strokeBorder(Color.white, lineWidth: 3)
                    .background(Circle().foregroundColor(correctedColor.color))
                    .offset(.init(width: 0, height: getPosition(size: proxy.size)))
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                DispatchQueue.global(qos: .background).async {
                                    let thumbRadius = proxy.size.width / 2
                                    let maxHeight = proxy.size.height - thumbRadius * 2

                                    let newPosition = (value.location.y - thumbRadius) / maxHeight

                                    let clamped = min(1.0, max(0, newPosition))

                                    DispatchQueue.main.async {
                                        hsb.hue = clamped * 360.0
                                    }
                                }
                            })
                    )
            }
        }
    }

    func getPosition(size: CGSize) -> CGFloat {
        let thumbRadius = size.width / 2

        let maxHeight = size.height - thumbRadius * 2

        let percent = hsb.hue / 360.0
        let half = maxHeight / 2
        let offset = maxHeight * percent
        return offset - half
    }
}

struct ColorHueSlider_Previews: PreviewProvider {
    static var previews: some View {
        ColorHueSlider(hsb: .constant(.init(hue: 0, saturation: 1.0, brightness: 1.0)))
            .frame(width: 25, height: 200)
    }
}
