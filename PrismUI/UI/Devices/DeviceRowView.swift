//
//  CompDeviceRowView.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/17/22.
//

import SwiftUI
import ComposableArchitecture
import PrismClient

struct DeviceRowView: View {
    let store: Store<Device, DeviceAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationLink (
                destination: LazyView(DeviceRouter.route(ssDevice: viewStore.state)),
                label: {
                    Image(viewStore.image)
                    Text(viewStore.name)
                }
            )
        }
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


//struct CompDeviceRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        CompDeviceRowView()
//    }
//}

