//
//  DevicesView.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/16/21.
//

import SwiftUI
import ComposableArchitecture

struct DevicesView: View {
    let store: Store<DevicesCore.State, DevicesCore.Action>

    var body: some View {
        NavigationView {
            List {
                WithViewStore(store.scope(state: \.devices)) { devicesViewStore in
                    ForEach(devicesViewStore.elements, id: \.self) { device in
                        NavigationLink {
                            LazyView(
                                DeviceRouter.route(device: device)
                            )
                        } label: {
                            Image(device.image)
                            Text(device.name)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .frame(minWidth: 225)

            Text("Welcome to PrismUI!")
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    ViewStore(store).send(.toggleSidebar)
                } label: {
                    Image(systemName: "sidebar.leading")
                }
            }
        }
        .onAppear {
            ViewStore(store).send(.onAppear)
        }
    }
}

//struct DevicesView_Previews: PreviewProvider {
//    static var previews: some View {
//        DevicesView(
//            store: .init(
//                initialState: .init(),
//                reducer: DevicesCore.reducer,
//                environment: .init(
//                    prismManager: .mock
//                )
//            )
//        )
//    }
//}

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
