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
            DeviceRowView(device: device)
        }
        .listStyle(.sidebar)
        .frame(minWidth: 225)
        .onAppear {
            viewModel.apply(.onAppear)
        }
    }
}

struct DeviceList_Previews: PreviewProvider {
    static var previews: some View {
        DevicesView()
    }
}
