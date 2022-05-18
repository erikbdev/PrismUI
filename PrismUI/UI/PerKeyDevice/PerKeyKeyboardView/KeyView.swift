//
//  KeyView.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/19/21.
//

import SwiftUI
import PrismKit

struct KeyView: View, Equatable {
    static func == (lhs: KeyView, rhs: KeyView) -> Bool {
        lhs.viewModel == rhs.viewModel && lhs.selected == rhs.selected
    }

    @ObservedObject var viewModel: KeyViewModel

    var selected = false

    var body: some View {
        ZStack {
            Rectangle()
                .fill(viewModel.output.color.color)
                .opacity(0.4)
                .overlay(
                    Rectangle()
                        .strokeBorder(viewModel.output.color.color, lineWidth: selected ? 3 : 0)
                )

            Circle()
                .fill(viewModel.output.color.color)
                .frame(width: 10, height: 10, alignment: .topLeading)
                .position(x: 10, y: 10)

            Text(viewModel.output.name)
                .fontWeight(.heavy)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .cornerRadius(4)
        .onTapGesture {
            viewModel.input.tappedTrigger.send()
        }
    }
}


//struct KeyView: View, Equatable {
//    static func == (lhs: KeyView, rhs: KeyView) -> Bool {
//        lhs.item == rhs.item && lhs.selected == rhs.selected
//    }
//
//    let item: SSKey
//    let selected: Bool
//    let action: () -> Void
//
//    @State var progress = 0.0
//
//    init(item: SSKey, selected: Bool, action: @escaping () -> Void) {
//        self.item = item
//        self.selected = selected
//        self.action = action
//    }
//
//    var duration: CGFloat {
//        CGFloat(item.effect?.duration ?? 0) / 10.0
//    }
//
//    var body: some View {
//        ZStack {
//            Rectangle()
//                .fill(color)
//                .opacity(0.4)
//                .overlay(
//                    Rectangle()
//                        .strokeBorder(color, lineWidth: selected ? 3 : 0)
//                )
//
//            Circle()
//                .fill(color)
//                .frame(width: 10, height: 10, alignment: .topLeading)
//                .position(x: 10, y: 10)
//
//            Text(item.name)
//                .fontWeight(.heavy)
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//        }
//        .cornerRadius(4)
//        .onTapGesture {
//            action()
//        }
//    }
//
//    var color: Color {
//        if let effect = item.effect {
//            let transitions = effect.transitions
//            return RGB.getColorFromTransition(with: progress,
//                                              transitions: transitions).color
//        } else {
//            return item.main.color
//        }
//    }
//}

//struct PerKeyView_Previews: PreviewProvider {
//    static var previews: some View {
//        KeyView(viewModel: KeyViewModel(ssKey: .empty, model: .perKeyGS65))
//    }
//}
