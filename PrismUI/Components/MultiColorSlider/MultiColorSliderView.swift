//
//  MultiColorSliderView.swift
//  PrismUI
//
//  Created by Erik Bautista on 12/22/21.
//

import SwiftUI
import PrismKit
import OrderedCollections

struct ColorSelector {
    var rgb: RGB
    var position: CGFloat // Value from 0 to 1.0
    var yOffset: CGFloat = -1
}

extension ColorSelector: Identifiable, Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

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

    private var maxSelectors: Int {
        if backgroundType == .gradient {
            return 16
        } else {
            return 4
        }
    }

    private let thumbSize = 16.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                Background
                    .shadow(radius: 0, x: 0, y: 0)
                    .onTouch(type: .ended, limitToBounds: true) { point in
                        handleAddingNewSelector(at: point, geometry: geometry)
                    }

                ForEach($selectors.indices, id: \.self) { index in
                    ArrowThumbView(color: selectors[index].rgb, selected: selected == index)
                        .frame(width: thumbSize, height: thumbSize)
                        .contentShape(Rectangle())
                        .position(x: getThumbPosition(size: geometry.size,
                                                      position: selectors[index].position),
                                  y: getThumbYOffset(geometry: geometry, selector: selectors[index]))
                        .gesture(
                            TapGesture()
                                .onEnded({ _ in
                                    handleThumbSelectionChanged(index: index)
                                })
                        )
                        .gesture(
                            DragGesture(minimumDistance: 0.0)
                                .onChanged({ value in
                                    // TODO: Fix thumb positioin
                                    handleThumbDragged(geometry: geometry,
                                                       value: value,
                                                       element: $selectors[index])
                                })
                                .onEnded({ value in
                                    handleThumbDragEnded(at: value, index: index, geometry: geometry)
                                })
                        )
                }
            }
            .shadow(radius: 0)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    @ViewBuilder
    private var Background: some View {
        if backgroundType == .gradient {
            RoundedRectangle(cornerSize: CGSize(width: 8, height: 8))
                .fill(
                    LinearGradient(stops: getGradientColors()
                                    .map({ .init(color: Color(red: $0.rgb.red, green: $0.rgb.green, blue: $0.rgb.blue),
                                                 location: $0.position) }),
                                   startPoint: .leading,
                                   endPoint: .trailing))
                .padding(.bottom, thumbSize + 2)
        } else {
            RoundedRectangle(cornerSize: CGSize(width: 8, height: 8))
                .fill(
                    LinearGradient(stops: getBreathingColors()
                                    .map({ .init(color: Color(red: $0.rgb.red, green: $0.rgb.green, blue: $0.rgb.blue),
                                                 location: $0.position) }),
                                   startPoint: .leading,
                                   endPoint: .trailing))
                .padding(.bottom, thumbSize + 2)
        }
    }
}

// Color methods
extension MultiColorSliderView {
    private func getGradientColors() -> [ColorSelector] {
        var sortedArray = selectors.sorted(by: { $0.position < $1.position })
        sortedArray.append(ColorSelector(rgb: selectors[0].rgb, position: 1.0))
        return sortedArray
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
}

// Handlers

extension MultiColorSliderView {
    private func handleAddingNewSelector(at point: CGPoint, geometry: GeometryProxy) {
        selected = -1

        guard selectors.count < maxSelectors else { return }

        // Avoid adding point near or on a selector
        let widthPercentage = point.x / geometry.size.width
        let widthRange = thumbSize / geometry.size.width
        let nearSelectors = selectors.filter { selector in
            let minRange = selector.position - widthRange
            let maxRange = selector.position + widthRange
            return widthPercentage >= minRange && widthPercentage <= maxRange
        }
        guard nearSelectors.count == 0 else { return }

        // Add selector
        let color = getColorFromGradient(with: widthPercentage)
        let newSelector = ColorSelector(rgb: color, position: widthPercentage)
        withAnimation(.easeIn(duration: 0.10)) {
            selectors.append(newSelector)
        }
    }

    private func handleThumbSelectionChanged(index: Int) {
        if selected == -1 {
            selected = index
        } else if selected == index {
            selected = -1
        } else {
            selected = index
        }
    }

    private func handleThumbDragged(geometry: GeometryProxy,
                                    value: DragGesture.Value,
                                    element: Binding<ColorSelector>) {
        selected = -1

        let containerWidth = geometry.size.width

        var dragOffsetWidth = value.location.x / containerWidth
        if dragOffsetWidth < 0 {
            dragOffsetWidth = 0
        } else if dragOffsetWidth > 1.0 {
            dragOffsetWidth = 1.0
        }
        element.position.wrappedValue = dragOffsetWidth

        guard selectors.count > 1 else { return }
        let containerHeight = geometry.size.height - thumbSize
        
        if value.location.y - containerHeight > containerHeight {
            element.yOffset.wrappedValue = value.location.y
        } else {
            element.yOffset.wrappedValue = geometry.size.height - (thumbSize / 2)
        }
    }

    private func handleThumbDragEnded(at value: DragGesture.Value, index: Int, geometry: GeometryProxy) {
        let containerHeight = geometry.size.height - thumbSize

        guard selectors.count > 1 else { return }
        if value.location.y - containerHeight > containerHeight {
            selectors.remove(at: index)
        }
    }
}

// Getters

extension MultiColorSliderView {
    private func getThumbYOffset(geometry: GeometryProxy, selector: ColorSelector) -> CGFloat {
        if selector.yOffset == -1 {
            return geometry.size.height - (thumbSize / 2)
        }

        return selector.yOffset
    }

    private func getThumbPosition(size: CGSize, position: CGFloat) -> CGFloat {
        let thumbRadius = thumbSize / 2
        let lowerBound = thumbRadius
        let midBound = size.width - thumbSize
        let upperBound = thumbRadius

        var location: CGFloat = 0
        location += lowerBound
        location += midBound * position
        location += upperBound
        return size.width * position
    }

    private func getColorFromGradient(with position: CGFloat) -> RGB {
        guard !selectors.isEmpty else { return .init(red: 0, green: 0, blue: 0) }

        var transitions: [ColorSelector] = []

        if backgroundType == .breathing {
            transitions = getBreathingColors()
        } else {
            transitions = getGradientColors()
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
            .frame(width: 400, height: 60)
    }
}
