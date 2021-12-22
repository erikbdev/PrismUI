//
//  MultiColorSliderView.swift
//  PrismUI
//
//  Created by Erik Bautista on 12/22/21.
//

import SwiftUI
import PrismKit

struct ColorPosition {
    var rgb: RGB
    var position: CGFloat // Value from 0 to 1.0
}

extension ColorPosition: Hashable { }

struct MultiColorSliderView: View {
    @State var colorPositions: [ColorPosition]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                Capsule()
                    .fill(
                        LinearGradient(stops: colorPositions
                                        .sorted(by: { $0.position < $1.position })
                                        .map({ .init(color: $0.rgb.color,
                                                                         location: $0.position) }),
                                       startPoint: .leading,
                                       endPoint: .trailing)
                    )

                ForEach(0..<colorPositions.count) { index in
//                if let element = $colorPositions.first {
                    ThumbView(color: $colorPositions[index].rgb)
                        .frame(width: geometry.size.height,
                               height: geometry.size.height)
                        .position(x: geometry.size.width * $colorPositions[index].wrappedValue.position, y: geometry.size.height / 2)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged({ value in
                                    var dragOffsetWidth = value.location.x / geometry.size.width
                                    if dragOffsetWidth < 0 {
                                        dragOffsetWidth = 0
                                    } else if dragOffsetWidth > 1.0 {
                                        dragOffsetWidth = 1.0
                                    }
                                    $colorPositions[index].position.wrappedValue = dragOffsetWidth
                                })
                        )
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct MultiColorSliderView_Previews: PreviewProvider {
    static var previews: some View {
        MultiColorSliderView(colorPositions: .init(
            [
                ColorPosition(rgb: .init(red: 0.0, green: 1.0, blue: 0.5), position: 0),
//                ColorPosition(color: .init(red: 1.0, green: 1.0, blue: 0.0), position: 0.5),
//                ColorPosition(color: .init(red: 1.0, green: 0.0, blue: 1.0), position: 1.0)
            ]))
            .frame(width: 400, height: 40)
    }
}
