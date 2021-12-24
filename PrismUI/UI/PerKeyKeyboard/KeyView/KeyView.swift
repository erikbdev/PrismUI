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
                    .strokeBorder(Color(red: viewModel.ssKey.main.red,
                                        green: viewModel.ssKey.main.green,
                                        blue: viewModel.ssKey.main.blue),
                                  lineWidth: viewModel.selected ? 3 : 0)
                    .background(Rectangle().fill(Color(red: viewModel.ssKey.main.red,
                                                       green: viewModel.ssKey.main.green,
                                                       blue: viewModel.ssKey.main.blue)
                                                    .opacity(0.4)))
            )
            .cornerRadius(4)
            .onTapGesture {
                withAnimation(Animation.easeIn(duration: 0.15)) {
                    viewModel.selected.toggle()
                }
            }
    }
}

struct PerKeyView_Previews: PreviewProvider {
    static var previews: some View {
        KeyView(viewModel: KeyViewModel(ssKey: .empty))
    }
}
