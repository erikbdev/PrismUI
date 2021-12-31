//
//  KeyView.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/19/21.
//

import SwiftUI
import PrismKit

struct KeyView: View {
    @ObservedObject var viewModel: KeyViewModel

    var body: some View {
            Text("\(viewModel.ssKey.name)")
                .fontWeight(.heavy)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(
                    Rectangle()
                        .strokeBorder(
                            keyColor,
                            lineWidth: viewModel.selected ? 3 : 0)
                        .background(
                            Rectangle()
                                .fill(keyColor)
                                .opacity(0.4)
                        )
                )
                .cornerRadius(4)
                .onTapGesture {
                    withAnimation(Animation.easeIn(duration: 0.15)) {
                        viewModel.selected.toggle()
                    }
                }
                .onAppear {
                    viewModel.apply(.onAppear)
                }
    }

    var keyColor: Color {
        var color = RGB()

        if viewModel.mode == .steady ||
            viewModel.mode == .reactive ||
            viewModel.mode == .disabled {
            color = viewModel.ssKey.main
        } else if viewModel.mode == .colorShift ||
                    viewModel.mode == .breathing {
            color = viewModel.getColor()
        }
        return Color(red: color.red, green: color.green, blue: color.blue)
    }
}

struct PerKeyView_Previews: PreviewProvider {
    static var previews: some View {
        KeyView(viewModel: KeyViewModel(ssKey: .empty, model: .perKeyGS65))
    }
}
