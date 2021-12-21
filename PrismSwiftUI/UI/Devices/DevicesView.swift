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
        .listStyle(SidebarListStyle())
        .onAppear {
            viewModel.apply(.onAppear)
        }
    }

    struct DevicesRowView: View {
        @State var device: SSDevice

        var body: some View {
            NavigationLink (
                destination: DeviceRouter.route(ssDevice: device),
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
