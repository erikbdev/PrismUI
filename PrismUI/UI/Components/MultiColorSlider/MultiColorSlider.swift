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

extension ColorSelector: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(rgb)
        hasher.combine(position)
        hasher.combine(yOffset)
    }
}

enum MultiColorSliderBackgroundStyle {
    case gradient
    case breathing
}

struct MultiColorSlider: View {
    @Binding var selectors: [ColorSelector]
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

                ForEach(selectors.indices, id: \.self) { index in
                    RoundedTriangle()
                        .modifier(
                            PopUpColorPicker(hsb: $selectors[index].rgb.hsb)
                        )
                        .frame(width: thumbSize, height: thumbSize)
                        .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                        .contentShape(Rectangle())
                        .position(x: getThumbXPosition(size: geometry.size, selector: selectors[index]),
                                  y: getThumbYOffset(size: geometry.size, selector: selectors[index]))
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0.0)
                                .onChanged({ value in
                                    // TODO: Fix thumb position
                                    handleThumbDragged(value: value, index: index, geometry: geometry)
                                })
                                .onEnded({ value in
                                    handleThumbDragEnded(value: value, index: index, geometry: geometry)
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
        RoundedRectangle(cornerSize: CGSize(width: 8, height: 8))
            .fill(
                LinearGradient(stops: (backgroundType == .gradient ? getGradientColors() : getBreathingColors())
                                .map({ .init(color: $0.rgb.color,
                                             location: $0.position) }),
                               startPoint: .leading,
                               endPoint: .trailing))
            .padding(.bottom, thumbSize + 2)
    }
}

// Color methods

extension MultiColorSlider {
    private func getGradientColors() -> [ColorSelector] {
        var sortedArray = selectors.sorted(by: { $0.position < $1.position })
        sortedArray.append(ColorSelector(rgb: selectors[0].rgb, position: 1.0))
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
            newArray.append(ColorSelector(rgb: RGB(), position: halfDistance))
        }

        newArray.append(ColorSelector(rgb: selectors[0].rgb, position: 1.0))
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
        let nearSelectors = selectors.filter { selector in
            let minRange = selector.position - widthRange
            let maxRange = selector.position + widthRange
            return widthPercentage >= minRange && widthPercentage <= maxRange
        }
        guard nearSelectors.count == 0 else { return }

        // Add selector
        let color = getColorFromGradient(with: widthPercentage)
        let newSelector = ColorSelector(rgb: color, position: widthPercentage)

        withAnimation {
            selectors.append(newSelector)
        }
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

        if selectors[index].position != dragOffsetWidth {
            selectors[index].position = dragOffsetWidth
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

        withAnimation {
            if value.location.y - containerHeight > containerHeight {
                selectors.remove(at: index)
            } else {
                selectors[index].yOffset = minSelectorCenterY
            }
        }
    }
}

// Getters

extension MultiColorSlider {
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
        MultiColorSlider(selectors: .constant(
            [
                ColorSelector(rgb: .init(red: 0.0, green: 1.0, blue: 0.5), position: 0),
                ColorSelector(rgb: .init(red: 1.0, green: 1.0, blue: 0.0), position: 0.5),
                ColorSelector(rgb: .init(red: 1.0, green: 0.0, blue: 1.0), position: 1.0)
            ]), backgroundType: .constant(.gradient))
            .frame(width: 300, height: 60)
    }
}
