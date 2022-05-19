//
//  DevicesView.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/16/21.
//

import SwiftUI
import ComposableArchitecture
import PrismClient

struct DevicesView: View {
    let store: Store<DevicesState, DevicesAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                List {
                    ForEachStore(
                        store.scope(
                            state: \.devices,
                            action: DevicesAction.device(id:action:)
                        ),
                        content: DeviceRowView.init(store:)
                    )
                }
                .listStyle(.sidebar)
                .frame(minWidth: 225)

                Text("Welcome to PrismUI!")
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: { viewStore.send(.toggleSidebar) }, label: { // 1
                        Image(systemName: "sidebar.leading")
                    })
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

//struct DeviceList_Previews: PreviewProvider {
//    static var previews: some View {
//        DevicesView(
//            store: Store(
//                initialState: DevicesState(
//                    devices: [
//                        Device(
//                            name: "Test 1",
//                            image: "PerKeyKeyboard",
//                            model: .perKey
//                        ),
//                        SSDevice(
//                            name: "Test 2",
//                            image: "PerKeyKeyboard",
//                            model: .perKeyGS65
//                        ),
//                        SSDevice(
//                            name: "Test 3",
//                            image: "PerKeyKeyboard",
//                            model: .unknown
//                        )
//                    ]
//                ),
//                reducer: devicesReducer,
//                environment: DevicesEnvironment(
//                    devicesManager: .live
//                )
//            )
//        )
//    }
//}
