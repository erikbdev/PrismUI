//
//  MultiColorSliderView.swift
//  PrismUI
//
//  Created by Erik Bautista on 12/22/21.
//

import SwiftUI
import PrismKit

struct ColorSelector {
    var rgb: RGB
    var position: CGFloat // Value from 0 to 1.0
    var yOffset: CGFloat = -1
}

extension ColorSelector: Identifiable, Hashable {
    var id: Int {
        var hasher = Hasher()
        hasher.combine(rgb)
        hasher.combine(position)
        hasher.combine(yOffset)
        return hasher.finalize()
    }
}

struct MultiColorSliderView: View {
    @Binding var selectors: [ColorSelector]
    @Binding var selected: Int

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                Capsule()
                    .fill(
                        LinearGradient(stops: selectors
                                        .sorted(by: { $0.position < $1.position })
                                        .map({ .init(color: Color(red: $0.rgb.red, green: $0.rgb.green, blue: $0.rgb.blue),
                                                     location: $0.position) }),
                                       startPoint: .leading,
                                       endPoint: .trailing)
                    )
                    .shadow(radius: 0, x: 0, y: 0)
                    .onTapGesture {
                        // TODO: Add another thumb if clicked anywhere in capsule.
                    }

                ForEach($selectors.indices, id: \.self) { index in
                    ThumbView(color: $selectors[index].rgb.wrappedValue)
                        .overlay(Circle()
                                    .strokeBorder(.black.opacity(0.5),
                                                  lineWidth: selected == index ? 3 : 0)
                        )
                        .frame(width: geometry.size.height,
                               height: geometry.size.height)
                        .position(x: getThumbPosition(size: geometry.size,
                                                      position: $selectors[index].position.wrappedValue),
                                  y: getThumbYOffset(geometry: geometry, selector: $selectors[index]))
                        .onTapGesture {
//                            withAnimation(.easeIn(duration: 0.10)) {
                                if selected == -1 {
                                    selected = index
                                } else if selected == index {
                                    selected = -1
                                } else {
                                    selected = index
                                }
//                            }
                        }
                        .gesture(
                            DragGesture(minimumDistance: 0.0)
                                .onChanged({ value in
                                    selected = -1
                                    handleThumbPositionChanged(geometry: geometry,
                                                               value: value,
                                                               element: $selectors[index])
                                })
                                .onEnded({ value in
                                    let containerHeight = geometry.size.height

                                    if value.location.y - (containerHeight / 2) > containerHeight * 2 {
                                        guard selectors.count > 1 else { return }
                                        selectors.remove(at: index)
                                    }
                                })
                        )
                }
            }
            .shadow(radius: 0, x: 0, y: 0)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    private func getThumbYOffset(geometry: GeometryProxy, selector: Binding<ColorSelector>) -> CGFloat {
        if selector.yOffset.wrappedValue == -1 {
            return geometry.size.height / 2
        }

        return selector.yOffset.wrappedValue
    }

    private func handleThumbPositionChanged(geometry: GeometryProxy,
                                            value: DragGesture.Value,
                                            element: Binding<ColorSelector>) {
        let containerWidth = geometry.size.width

        var dragOffsetWidth = value.location.x / (containerWidth)
        if dragOffsetWidth < 0 {
            dragOffsetWidth = 0
        } else if dragOffsetWidth > 1.0 {
            dragOffsetWidth = 1.0
        }
        element.position.wrappedValue = dragOffsetWidth

        // TODO: Handle Y axis if dragged outside
        guard selectors.count > 1 else { return }
        let containerHeight = geometry.size.height

//        withAnimation {
            if value.location.y - containerHeight / 2 > containerHeight * 2 {
                element.yOffset.wrappedValue = value.location.y
            } else {
                element.yOffset.wrappedValue = geometry.size.height / 2
//            }
        }
    }

    // TODO: Fix issue with slider not centering with mouse in the future.
    private func getThumbPosition(size: CGSize, position: CGFloat) -> CGFloat {
        let thumbRadius = size.height / 2
        let lowerBound = thumbRadius
        let midBound = size.width - size.height
        let upperBound = thumbRadius

        var location: CGFloat = 0
        location += lowerBound
        location += midBound * position
        location += upperBound
        return size.width * position
    }
}

struct MultiColorSliderView_Previews: PreviewProvider {
    static var previews: some View {
        MultiColorSliderView(selectors: .constant(
            [
                ColorSelector(rgb: .init(red: 0.0, green: 1.0, blue: 0.5), position: 0),
                ColorSelector(rgb: .init(red: 1.0, green: 1.0, blue: 0.0), position: 0.5),
                ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 1.0), position: 1.0)
            ]), selected: .constant(-1))
            .frame(width: 400, height: 40)
    }
}
