//
//  CompDeviceRowView.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/17/22.
//

import SwiftUI
import ComposableArchitecture

struct CompDeviceRowView: View {
    let store: Store<DeviceModel, DeviceAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationLink (
                destination: Text("Ayooo"),
                label: {
                    Image(viewStore.image)
                    Text(viewStore.name)
                }
            )
        }
    }
}

//struct CompDeviceRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        CompDeviceRowView()
//    }
//}
