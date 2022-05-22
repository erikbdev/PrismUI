//
//  PerKeyKeyboardViewComp.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/21/22.
//

import SwiftUI
import ComposableArchitecture
import PrismClient

struct PerKeyKeyboardViewComp: View {
    let store: Store<PerKeyKeyboardState, PerKeyKeyboardAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            let padding = 6.0

            VStack(spacing: padding) {
                let keyCodes = PerKeyProperties.getKeyboardCodes(for: viewStore.model)

                ForEach(keyCodes.indices, id: \.self) { row in
                    HStack(alignment: .top, spacing: padding) {
                        ForEach(keyCodes[row].indices, id: \.self) { column in
                            let keyCode = keyCodes[row][column]
                            let keyId: UInt16 = (UInt16(keyCode.0) << 8) | UInt16(keyCode.1)

                            let keyStore = store.scope(
                                state: { state in
                                    state.keys[id: keyId] ?? .init(key: .empty)
                                },
                                action: { .key(id: keyId, action: $0) }
                            )

                            WithViewStore(keyStore) { keyViewStore in
                                let keyLayout = PerKeyProperties.getKeyLayout(
                                    for: keyViewStore.state.key,
                                       model: viewStore.model,
                                       padding: padding
                                )

                                if let keyLayout = keyLayout {
                                    KeyComp(store: keyStore)
                                        .frame(
                                            minWidth: keyLayout.width,
                                            minHeight: keyLayout.height,
                                            maxHeight: keyLayout.height)
                                        .offset(y: keyLayout.yOffset)

                                    if keyLayout.requiresExtraView {
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(
                                                minWidth: keyLayout.width,
                                                minHeight: keyLayout.height,
                                                maxHeight: keyLayout.height)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .animation(.easeIn(duration: 0.25), value: viewStore.selected)
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct PerKeyKeyboardViewComp_Previews: PreviewProvider {
    static var previews: some View {
        PerKeyKeyboardViewComp(
            store: .init(
                initialState: .init(model: .perKey),
                reducer: perKeyKeyboardReducer,
                environment: .init()
            )
        )
            .frame(width: 1200, height: 400)
    }
}
