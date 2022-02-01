//
//  ArrowThumbView.swift
//  PrismUI
//
//  Created by Erik Bautista on 12/31/21.
//

import SwiftUI
import PrismKit
import CombineExt

struct ArrowThumbView: View {
    var color: RGB
    var selected = false

    var body: some View {
        GeometryReader { geometry in
            Triangle()
                .stroke(colorView, style:
                            StrokeStyle(lineWidth: returnSmallestSize(geometry: geometry) / 4,
                                        lineCap: .round,
                                        lineJoin: .round)
                )
                .background(Triangle().fill(colorView))
                .overlay(
                    Triangle()
                        .stroke(.black.opacity(0.25), style:
                                    StrokeStyle(lineWidth: selected ? returnSmallestSize(geometry: geometry) / 2 : 0,
                                                lineCap: .round,
                                                lineJoin: .round)
                               )
                )
                .padding(returnSmallestSize(geometry: geometry) / 4)
                .frame(width: returnSmallestSize(geometry: geometry),
                       height: returnSmallestSize(geometry: geometry),
                       alignment: .bottom)
                .offset(y: geometry.size.height - returnSmallestSize(geometry: geometry))
        }
        .frame(alignment: .bottom)
    }

    func returnSmallestSize(geometry: GeometryProxy) -> CGFloat {
        return min(geometry.size.width, geometry.size.height)
    }

    var colorView: Color {
        return Color(red: color.red, green: color.green, blue: color.blue)
    }
}

struct Triangle : Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct ArrowThumbView_Previews: PreviewProvider {
    static var previews: some View {
        ArrowThumbView(color: .init(red: 0, green: 0, blue: 1.0))
            .frame(width: 80, height: 120)
    }
}
