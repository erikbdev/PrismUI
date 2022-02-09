//
//  DevicesView.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/16/21.
//

import SwiftUI
import PrismKit

struct DevicesView: View {
    @EnvironmentObject var prismDriverService: PrismDriverService

    var body: some View {
        List(prismDriverService.devices, id: \.self) { device in
            DeviceRowView(device: device)
        }
        .listStyle(.sidebar)
        .frame(minWidth: 225)
    }
}

struct DeviceList_Previews: PreviewProvider {
    static var previews: some View {
        DevicesView()
            .environmentObject(PrismDriverService())
    }
}
