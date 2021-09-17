//
//  DevicesView.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/16/21.
//

import SwiftUI
import PrismKit

struct DevicesView: View {
    @Binding private var devices: [Device]

    init(devices: Binding<[Device]> = .constant([])) {
        self._devices = devices
    }

    var body: some View {
        List {
            ForEach(devices, id: \.id) { device in
                NavigationLink (
                    destination: DeviceRouter.route(device: device),
                    label: {
                        Image(device.image)
                        Text(device.name)
                    }
                )
            }
        }.listStyle(SidebarListStyle())
    }
}

struct DeviceList_Previews: PreviewProvider {
    static var previews: some View {
        DevicesView()
    }
}
