//
//  KeyComp.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/22/22.
//

import SwiftUI
import ComposableArchitecture
import PrismClient

struct KeyComp: View {
    let store: Store<KeyCore.State, KeyCore.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Rectangle()
                    .fill(viewStore.key.main.color)
                    .opacity(0.4)
                    .overlay(
                        Rectangle()
                            .strokeBorder(
                                viewStore.key.main.color,
                                lineWidth: viewStore.selected ? 3 : 0
                            )
                    )

                Circle()
                    .fill(viewStore.key.main.color)
                    .frame(
                        width: 10,
                        height: 10,
                        alignment: .topLeading
                    )
                    .position(x: 10, y: 10)

                Text(viewStore.key.name)
                    .fontWeight(.heavy)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .cornerRadius(4)
            .onTapGesture {
                viewStore.send(.toggleSelected)
            }
        }
    }
}

//struct KeyComp_Previews: PreviewProvider {
//    static var previews: some View {
//        KeyComp(
//            store: .init(
//                initialState: .init(name: <#String#>, color: <#RGB#>),
//                reducer: KeyCore.reducer,
//                environment: .init(
//                    key: <#Key#>
//                )
//            )
//        )
//    }
//}
