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
                    ForEach(viewStore.devices, id: \.self) { device in
                        NavigationLink {
                            LazyView(DeviceRouter.route(device: device))
                        } label: {
                            Image(device.image)
                            Text(device.name)
                        }
                    }
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

struct DevicesView_Previews: PreviewProvider {
    static var previews: some View {
        DevicesView(
            store: Store(
                initialState: .init(),
                reducer: devicesReducer,
                environment: DevicesEnvironment(
                    deviceScanner: .mock
                )
            )
        )
    }
}

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
