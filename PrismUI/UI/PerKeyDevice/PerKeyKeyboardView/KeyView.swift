//
//  KeyView.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/19/21.
//

import SwiftUI
import PrismKit

struct KeyView: View {
    let item: SSKey
    let selected: Bool
    let action: () -> Void

    @State var progress = 0.0

    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
                .opacity(0.4)
                .overlay(
                    Rectangle()
                        .strokeBorder(color, lineWidth: selected ? 3 : 0)
                )

            Circle()
                .fill(color)
                .frame(width: 10, height: 10, alignment: .topLeading)
                .position(x: 10, y: 10)

            Text(item.name)
                .fontWeight(.heavy)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .cornerRadius(4)
        .onTapGesture {
            action()
        }
    }

    var color: Color {
        if let effect = item.effect {
            let transitions = effect.transitions
            return RGB.getColorFromTransition(with: progress,
                                              transitions: transitions).color
        } else {
            return item.main.color
        }
    }

//    static func == (lhs: KeyView, rhs: KeyView) -> Bool {
//        lhs.viewModel == rhs.viewModel
//    }
}

//struct PerKeyView_Previews: PreviewProvider {
//    static var previews: some View {
//        KeyView(viewModel: KeyViewModel(ssKey: .empty, model: .perKeyGS65))
//    }
//}
