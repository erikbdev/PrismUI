//
//  ThumbView.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/17/21.
//

import SwiftUI
import PrismKit

struct ThumbView: View {
    @Binding var color: RGB

    var body: some View {
        GeometryReader { geometry in
            Circle()
                .fill(color.color)
                .frame(width: geometry.size.height,
                       height: geometry.size.height)
                .overlay(
                    Circle()
                        .strokeBorder(Color(red: 1, green: 1, blue: 1), lineWidth: 2)
                )
                .shadow(radius: 8, x: 0, y: 2)
        }
    }
}

struct ThumbView_Previews: PreviewProvider {
    static var previews: some View {
        ThumbView(color: .constant(.init(red: 0.0, green: 0.5, blue: 0.5)))
            .frame(width: 60, height: 60)
    }
}
