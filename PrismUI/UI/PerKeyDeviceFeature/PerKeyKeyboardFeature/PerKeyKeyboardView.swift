//
//  PerKeyKeyboardView.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/21/22.
//

import SwiftUI
import ComposableArchitecture
import PrismClient

struct PerKeyKeyboardView: View {
    let store: Store<PerKeyKeyboardCore.State, PerKeyKeyboardCore.Action>
    
    var body: some View {
        let padding = 6.0

        WithViewStore(store.scope(state: \.keysLoaded)) { _ in
            VStack(spacing: padding) {
                let keyCodes = PerKeyProperties.getKeyboardCodes(for: ViewStore(store).isLongKeyboard ? .perKey : .perKeyShort)

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
                                    model: ViewStore(store).isLongKeyboard ? .perKey : .perKeyShort,
                                    padding: padding
                                )
                                
                                if let keyLayout = keyLayout {
                                    KeyView(store: keyStore)
                                        .frame(
                                            minWidth: keyLayout.width,
                                            minHeight: keyLayout.height,
                                            maxHeight: keyLayout.height
                                        )
                                        .offset(y: keyLayout.yOffset)
                                    
                                    if keyLayout.requiresExtraView {
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(
                                                minWidth: keyLayout.width,
                                                minHeight: keyLayout.height,
                                                maxHeight: keyLayout.height
                                            )
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .onAppear {
                ViewStore(store).send(.onAppear)
            }

        }
    }
}

struct PerKeyKeyboardViewComp_Previews: PreviewProvider {
    static var previews: some View {
        PerKeyKeyboardView(
            store: .init(
                initialState: .init(
                    isLongKeyboard: true
                ),
                reducer: PerKeyKeyboardCore.reducer,
                environment: .init()
            )
        )
            .frame(width: 1200, height: 400)
    }
}
