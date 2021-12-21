// Modified version from https://github.com/Priva28/SwiftUIColourWheel/blob/master/Colour%20Wheel/Views/Experimental/NewColourWheel.swift

import SwiftUI
import PrismKit

/// The actual colour wheel view.
struct ColourWheelView: View {
    
    /// Draws at a specified radius.

    /// The HSV colour. Is a binding as it can change and the view will update when it does.
    @Binding var color: HSV
    private let thumbSize: CGFloat = 60

    var body: some View {
        /// Geometry reader so we can know more about the geometry around and within the view.
        GeometryReader { geometry in
            ZStack {
                /// The colour wheel. See the definition.
                AngularGradientHueView()
                    /// Smoothing out of the colours.
                    .blur(radius: 8)
                    .clipShape(Circle())
                    /// Outer shadow.
                    .shadow(radius: 15)

                /// Saturation value
                RadialGradient(gradient: Gradient(colors: [.white, .black]),
                               center: .center,
                               startRadius: 0,
                               endRadius: (minSize(geometry)/2) - 10)
                    .blendMode(.screen)

                /// The little knob that shows selected colour.
                Circle()
                    .fill(Color(hue: color.hue / 360.0,
                                saturation: color.saturation,
                                brightness: color.brightness))
                    .frame(width: thumbSize / 2,
                           height: thumbSize / 2)
                    .overlay(
                        Circle()
                            .strokeBorder(Color(red: 1, green: 1, blue: 1), lineWidth: 2)
                    )
                    .offset(x: (minSize(geometry) / 2) * color.saturation)
                    .rotationEffect(.degrees(-Double(color.hue)))
                    .shadow(radius: 8, x: 0, y: 2)
            }
            /// The gesture so we can detect taps and drags on the wheel.
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onChanged { value in
                        /// Work out angle which will be the hue.
                        let y = geometry.frame(in: .global).midY - value.location.y
                        let x = value.location.x - geometry.frame(in: .global).midX

                        /// Use `atan2` to get the angle from the center point then convert than into a 360 value with custom function(find it in helpers).
                        let hue = atan2To360(atan2(y, x))

                        /// Work out distance from the center point which will be the saturation.
                        let center = CGPoint(x: geometry.frame(in: .global).midX,
                                             y: geometry.frame(in: .global).midY)

                        /// Maximum value of sat is 1 so we find the smallest of 1 and the distance.
                        let saturation = min(distance(center, value.location) / (minSize(geometry) / 2), 1)

                        /// set the colour which will notify the views.
                        self.color = HSV(hue: hue, saturation: saturation, brightness: color.brightness)
                    }
            )
        }
        .padding(thumbSize / 4)
    }

    private func minSize(_ geometry: GeometryProxy) -> CGFloat {
        return min(geometry.size.width, geometry.size.height)
    }
    
    private func atan2To360(_ angle: CGFloat) -> CGFloat {
        var result = angle
        if result < 0 {
            result = (2 * CGFloat.pi) + angle
        }
        return result * 180 / CGFloat.pi
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
}

struct NewColourWheel_Previews: PreviewProvider {
    static var previews: some View {
        ColourWheelView(color: .constant(HSV(hue: 0, saturation: 0, brightness: 1)))
            .frame(width: 250, height: 250, alignment: .center)
    }
}
