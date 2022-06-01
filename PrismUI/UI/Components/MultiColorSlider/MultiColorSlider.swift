//
//  MultiColorSliderView.swift
//  PrismUI
//
//  Created by Erik Bautista on 12/22/21.
//

import SwiftUI
import PrismClient
import OrderedCollections

struct ColorSelector: Hashable {
    var color: RGB
    var position: CGFloat // Value from 0 to 1.0
    var yOffset: CGFloat = -1
}

struct MultiColorSlider: View {
    @Binding var selectors: [ColorSelector]
    @Binding var backgroundStyle: BackgroundStyle
    private let thumbSize = 16.0

    enum BackgroundStyle {
        case gradient
        case breathing
    }

    private var maxSelectors: Int {
        if backgroundStyle == .gradient {
            return 14
        } else {
            return 4
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                Background
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                    .onTouch(type: .ended, limitToBounds: true) { point in
                        handleAddingNewSelector(at: point, geometry: geometry)
                    }

                ForEach(selectors.indices, id: \.self) { index in
                    RoundedTriangle()
                        .frame(width: thumbSize, height: thumbSize)
                        .modifier(
                            PopUpColorPicker(color: $selectors[index].color.hsb)
                        )
                        .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                        .contentShape(Rectangle())
                        .position(
                            x: getThumbXPosition(size: geometry.size, selector: selectors[index]),
                            y: getThumbYOffset(size: geometry.size, selector: selectors[index])
                        )
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0.5)
                                .onChanged({ value in
                                    handleThumbDragged(value: value, index: index, geometry: geometry)
                                })
                                .onEnded({ value in
                                    handleThumbDragEnded(value: value, index: index, geometry: geometry)
                                })
                        )
                        .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 2)
                }
            }
            .shadow(radius: 0)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .animation(.linear(duration: 0.25), value: selectors)
        }
    }

    @ViewBuilder
    private var Background: some View {
        RoundedRectangle(
            cornerSize: CGSize(
                width: 8,
                height: 8
            )
        )
            .fill(
                LinearGradient(
                    stops: (backgroundStyle == .gradient ? getGradientColors() : getBreathingColors())
                        .map({
                            .init(
                                color: $0.color.color,
                                location: $0.position
                            )
                        }),
                    startPoint: .leading,
                    endPoint: .trailing
                )
        )
        .padding(.bottom, thumbSize + 2)
    }
}

// Color methods

extension MultiColorSlider {
    private func getGradientColors() -> [ColorSelector] {
        var sortedArray = selectors.sorted(by: { $0.position < $1.position })
        sortedArray.append(.init(color: selectors[0].color, position: 1.0))
        return sortedArray
    }

    private func getBreathingColors() -> [ColorSelector] {
        var newArray: [ColorSelector] = []
        let sortedSelectors = selectors.sorted(by: { $0.position < $1.position })

        for inx in sortedSelectors.indices {
            let selecor = sortedSelectors[inx]

            var halfDistance: CGFloat
            if (inx + 1) < sortedSelectors.count {
                let nextSelector = sortedSelectors[inx + 1]
                halfDistance = (nextSelector.position + selecor.position) / 2
            } else {
                halfDistance = (1 + selecor.position) / 2
            }

            newArray.append(selecor)
            newArray.append(ColorSelector(color: RGB(), position: halfDistance))
        }

        newArray.append(ColorSelector(color: selectors[0].color, position: 1.0))
        return newArray
    }
}

// Handlers

extension MultiColorSlider {
    private func handleAddingNewSelector(at point: CGPoint, geometry: GeometryProxy) {
        guard selectors.count < maxSelectors else { return }

        // Avoid adding point near or on a selector
        let widthPercentage = point.x / geometry.size.width
        let widthRange = thumbSize / geometry.size.width
        let nearSelectors = selectors.filter {
            $0.position - widthRange <= widthPercentage && widthPercentage <= $0.position + widthRange
        }

        guard nearSelectors.count == 0 else { return }

        // Add selector
        let color = getColorFromGradient(with: widthPercentage)
        let newSelector = ColorSelector(color: color, position: widthPercentage)

        selectors.append(newSelector)
    }

    private func handleThumbDragged(value: DragGesture.Value,
                                    index: Int,
                                    geometry: GeometryProxy) {

        let containerWidth = geometry.size.width

        var dragOffsetWidth = value.location.x / containerWidth
        if dragOffsetWidth < 0 {
            dragOffsetWidth = 0
        } else if dragOffsetWidth > 1.0 {
            dragOffsetWidth = 1.0
        }

        // There are no selectors in range, so we can add a selector

        if canSetSelector(at: dragOffsetWidth, exclude: index) {
            if selectors[index].position != dragOffsetWidth {
                selectors[index].position = dragOffsetWidth
            }
        }

        guard selectors.count > 1 else { return }

        let minSelectorCenterY = geometry.size.height - (thumbSize / 2)

        let offsetY = max(minSelectorCenterY, value.location.y)

        if selectors[index].yOffset != offsetY {
            selectors[index].yOffset = offsetY
        }
    }

    private func handleThumbDragEnded(value: DragGesture.Value, index: Int, geometry: GeometryProxy) {
        let containerHeight = geometry.size.height - thumbSize
        let minSelectorCenterY = geometry.size.height - (thumbSize / 2)

        guard selectors.count > 1 else { return }

        if value.location.y - containerHeight > containerHeight {
            selectors.remove(at: index)
        } else {
            if selectors[index].yOffset != minSelectorCenterY {
                selectors[index].yOffset = minSelectorCenterY
            }
        }
    }
}

// Getters

extension MultiColorSlider {

    private func canSetSelector(at position: CGFloat, exclude index: Int?) -> Bool {
        // Limit the percentage of one position only for one value.
        // The device may brick if there are multiple transitions with
        // the same position.

        let bounds = 0.01

        var filteredSelectors: [ColorSelector]

        if let index = index {
            filteredSelectors = selectors.enumerated().filter({ $0.offset != index }).map({ $0.element })
        } else {
            filteredSelectors = selectors
        }

        let selectorsWithinRange = filteredSelectors.filter {
            $0.position - bounds <= position && position <= $0.position + bounds
        }

        return selectorsWithinRange.count == 0
    }

    private func getThumbYOffset(size: CGSize, selector: ColorSelector) -> CGFloat {
        if selector.yOffset == -1 {
            return size.height - (thumbSize / 2) // Center Selector
        }

        return selector.yOffset
    }

    private func getThumbXPosition(size: CGSize, selector: ColorSelector) -> CGFloat {
        let thumbRadius = thumbSize / 2
        let lowerBound = thumbRadius
        let midBound = size.width - thumbSize
        let upperBound = thumbRadius

        var location: CGFloat = 0
        location += lowerBound
        location += midBound * selector.position
        location += upperBound
        return size.width * selector.position
    }

    private func getColorFromGradient(with position: CGFloat) -> RGB {
        guard !selectors.isEmpty else { return .init(red: 0, green: 0, blue: 0) }

        var transitions: [ColorSelector] = []

        if backgroundStyle == .breathing {
            transitions = getBreathingColors()
        } else {
            transitions = getGradientColors()
        }
        return RGB.getColorFromTransition(with: position, transitions: transitions)
    }
}

struct MultiColorSliderView_Previews: PreviewProvider {
    static var previews: some View {
        MultiColorSlider(selectors: .constant(
            [
                ColorSelector(color: .init(red: 0.0, green: 1.0, blue: 0.5), position: 0),
                ColorSelector(color: .init(red: 1.0, green: 1.0, blue: 0.0), position: 0.5),
                ColorSelector(color: .init(red: 1.0, green: 0.0, blue: 1.0), position: 1.0)
            ]), backgroundStyle: .constant(.gradient))
            .frame(width: 300, height: 60)
    }
}
