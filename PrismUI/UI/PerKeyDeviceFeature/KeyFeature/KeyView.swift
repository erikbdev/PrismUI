//
//  KeyView.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/22/22.
//

import SwiftUI
import ComposableArchitecture
import PrismClient

struct KeyView: View {
    let store: Store<KeyCore.State, KeyCore.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Rectangle()
                    .fill(viewStore.mainColor.color)
                    .opacity(0.4)
                    .overlay(
                        Rectangle()
                            .strokeBorder(
                                viewStore.mainColor.color,
                                lineWidth: viewStore.selected ? 3 : 0
                            )
                    )

                Circle()
                    .fill(viewStore.mainColor.color)
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
                viewStore.send(.toggleSelection)
            }
            .animation(.easeIn(duration: 0.25), value: viewStore.selected)
//            .animation(.easeIn, value: viewStore.mainColor)
        }
    }
}

struct KeyView_Previews: PreviewProvider {
    static var previews: some View {
        KeyView(
            store: .init(
                initialState: .init(
                    key: .empty
                ),
                reducer: KeyCore.reducer,
                environment: .init()
            )
        )
        .frame(width: 100, height: 100)
    }
}
