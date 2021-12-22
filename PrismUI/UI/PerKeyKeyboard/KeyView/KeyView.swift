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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(
                Rectangle()
                    .strokeBorder(viewModel.ssKey.main.color, lineWidth: viewModel.selected ? 3 : 0)
                    .background(Rectangle().fill(viewModel.ssKey.main.color.opacity(0.4)))
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
