//
//  DeviceRowView.swift
//  PrismUI
//
//  Created by Erik Bautista on 2/2/22.
//

import SwiftUI
import PrismKit

struct DeviceRowView: View {
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

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
