//
//  ArrowThumbView.swift
//  PrismUI
//
//  Created by Erik Bautista on 12/31/21.
//

import SwiftUI
import PrismClient
import CombineExt

struct ArrowThumbView: View {
    @Binding var rgb: RGB

    var body: some View {
        RoundedTriangle()
            .modifier(PopUpColorPicker(color: $rgb.hsb))
    }
}

struct RoundedTriangle : Shape {
    func path(in rect: CGRect) -> Path {
        let cornerRadius = rect.width / 8

        var path = Path()

        let point1 = CGPoint(x: rect.midX, y: rect.minY)
        let point2 = CGPoint(x: rect.maxX, y: rect.maxY)
        let point3 = CGPoint(x: rect.minX, y: rect.maxY)

        path.move(to: point1)
        path.addArc(tangent1End: point1, tangent2End: point2, radius: cornerRadius)
        path.addArc(tangent1End: point2, tangent2End: point3, radius: cornerRadius)
        path.addArc(tangent1End: point3, tangent2End: point1, radius: cornerRadius)
        path.addArc(tangent1End: point1, tangent2End: point2, radius: cornerRadius)
        path.closeSubpath()
        return path
    }
}

struct ArrowThumbView_Previews: PreviewProvider {
    static var previews: some View {
        ArrowThumbView(rgb: .constant(.init(red: 0, green: 0, blue: 1.0)))
            .frame(width: 80, height: 80)
    }
}
