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
        ZStack {
            VStack {
                // memory leak
//                Circle()
//                    .fill(Color(red: viewModel.ssKey.main.red,
//                                green: viewModel.ssKey.main.green,
//                                blue: viewModel.ssKey.main.blue))
//                    .frame(width: 12, height: 12)
//                    .padding(4)
                Text("\(viewModel.ssKey.name)")
                    .frame(alignment: .center)
            }
            if viewModel.selected {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(viewModel.ssKey.main.color, lineWidth: 3)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(viewModel.ssKey.main.color.opacity(0.4))
        )
        .onTapGesture {
            withAnimation(Animation.easeIn(duration: 0.15)) {
                viewModel.selected.toggle()
            }
        }
    }
}

//struct PerKeyView_Previews: PreviewProvider {
//    static var previews: some View {
//        KeyView(ssKey: SSKey.empty, ssDevice: SSDevice())
//    }
//}
