//
//  DevicesView.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/16/21.
//

import SwiftUI
import PrismKit

struct DevicesView: View {
    @ObservedObject var viewModel = DevicesViewModel()

    var body: some View {
        List(viewModel.devices, id: \.self) { device in
            DevicesRowView(device: device)
        }
        .listStyle(.sidebar)
        .frame(minWidth: 225)
        .onAppear {
            viewModel.apply(.onAppear)
        }
    }

    struct DevicesRowView: View {
        @State var device: SSDevice

        var body: some View {
            NavigationLink (
                destination: LazyView(DeviceRouter.route(ssDevice: device)),
                label: {
                    Image(device.image)
                    Text(device.name)
                }
            )
        }
    }
}

struct DeviceList_Previews: PreviewProvider {
    static var previews: some View {
        DevicesView()
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
