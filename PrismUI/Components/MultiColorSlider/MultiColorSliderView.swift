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

enum MultiColorSliderBackgroundStyle {
    case gradient
    case breathing
}

struct MultiColorSliderView: View {
    @Binding var selectors: [ColorSelector]
    @Binding var selected: Int
    @Binding var backgroundType: MultiColorSliderBackgroundStyle

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                Background
                    .shadow(radius: 0, x: 0, y: 0)
                    .onTouch(type: .ended, limitToBounds: true) { point in
                        // Add new thumb to the view
                        selected = -1
                        let widthPercentage = point.x / geometry.size.width
                        let color = getColorFromGradient(with: widthPercentage)
                        let newSelector = ColorSelector(rgb: color, position: widthPercentage)
                        withAnimation(.easeIn(duration: 0.10)) {
                            selectors.append(newSelector)
                        }
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
                        .gesture(
                            TapGesture()
                                .onEnded({ _ in
//                            withAnimation(.easeIn(duration: 0.10)) {
                                    if selected == -1 {
                                        selected = index
                                    } else if selected == index {
                                        selected = -1
                                    } else {
                                        selected = index
                                    }
 //                            }
                                })
                        )
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

    @ViewBuilder
    private var Background: some View {
        if backgroundType == .gradient {
            Capsule()
                .fill(
                    LinearGradient(stops: getGradientColors()
                                    .map({ .init(color: Color(red: $0.rgb.red, green: $0.rgb.green, blue: $0.rgb.blue),
                                                 location: $0.position) }),
                                   startPoint: .leading,
                                   endPoint: .trailing))
        } else {
            Capsule()
                .fill(
                    LinearGradient(stops: getBreathingColors()
                                    .map({ .init(color: Color(red: $0.rgb.red, green: $0.rgb.green, blue: $0.rgb.blue),
                                                 location: $0.position) }),
                                   startPoint: .leading,
                                   endPoint: .trailing))
        }
    }

    private func getGradientColors() -> [ColorSelector] {
        var newArray: [ColorSelector] = []
        newArray.append(contentsOf: selectors.sorted(by: { $0.position < $1.position }))
        newArray.append(ColorSelector(rgb: selectors[0].rgb, position: 1.0))
        return newArray
    }

    private func getBreathingColors() -> [ColorSelector] {
        var newArray: [ColorSelector] = []
        let sortedSelectors = selectors.sorted(by: { $0.position < $1.position })

        for inx in sortedSelectors.indices {
            let firstSelector = sortedSelectors[inx]
            newArray.append(firstSelector)

            var halfDistance: CGFloat
            if (inx + 1) < sortedSelectors.count {
                let secondSelector = sortedSelectors[inx + 1]
                halfDistance = (secondSelector.position + firstSelector.position) / 2
            } else {
                halfDistance = (1 + firstSelector.position) / 2
            }

            newArray.append(ColorSelector(rgb: RGB(), position: halfDistance))
        }

        newArray.append(ColorSelector(rgb: selectors[0].rgb, position: 1.0))
        return newArray
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

    private func getColorFromGradient(with position: CGFloat) -> RGB {
        guard !selectors.isEmpty else { return .init(red: 0, green: 0, blue: 0) }
        let baseTransitions = selectors.sorted(by: { $0.position < $1.position })

        var transitions: [ColorSelector] = []

        if backgroundType == .breathing {
            // We add the transitions from baseTransition and also add the half values between
            // each transition to have the breathing effect.
            for inx in baseTransitions.indices {
                let firstSelector = baseTransitions[inx]
                transitions.append(firstSelector)

                var halfDistance: CGFloat
                if (inx + 1) < baseTransitions.count {
                    let secondSelector = baseTransitions[inx + 1]
                    halfDistance = (secondSelector.position + firstSelector.position) / 2
                } else {
                    halfDistance = (1 + firstSelector.position) / 2
                }

                transitions.append(ColorSelector(rgb: RGB(), position: halfDistance))
            }
        } else {
            transitions = baseTransitions
        }
        return RGB.getColorFromTransition(with: position, transitions: transitions)
    }
}

struct MultiColorSliderView_Previews: PreviewProvider {
    static var previews: some View {
        MultiColorSliderView(selectors: .constant(
            [
                ColorSelector(rgb: .init(red: 0.0, green: 1.0, blue: 0.5), position: 0),
                ColorSelector(rgb: .init(red: 1.0, green: 1.0, blue: 0.0), position: 0.5),
                ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 1.0), position: 1.0)
            ]), selected: .constant(-1), backgroundType: .constant(.gradient))
            .frame(width: 400, height: 40)
    }
}
