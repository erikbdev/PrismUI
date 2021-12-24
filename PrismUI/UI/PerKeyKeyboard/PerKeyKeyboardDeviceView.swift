//
//  PerKeyKeyboardView.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/17/21.
//

import SwiftUI
import PrismKit


struct PerKeyKeyboardDeviceView: View {
    @ObservedObject private var viewModel: PerKeyKeyboardDeviceViewModel

    init (ssDevice: SSDevice) {
        let viewModel = PerKeyKeyboardDeviceViewModel(ssDevice: ssDevice)
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            if viewModel.finishedLoading {
                HSplitView {
                    ScrollView(.vertical, showsIndicators: true) {
                        KeySettingsView(keyModels: viewModel.selected) {
                            viewModel.apply(.onSubmit)
                        }
                    }
                    .padding()
                    KeyboardLayout
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture(perform: {
                            withAnimation {
                                viewModel.apply(.onTouchOutside)
                            }
                        })
                }
            } else {
                Text("Loading keys...")
            }
        }
        .toolbar {
            Picker("", selection: $viewModel.mouseMode) {
                Image(systemName: "cursorarrow").tag(0)
                Image(systemName: "cursorarrow.rays").tag(1)
            }
            .pickerStyle(.segmented)
        }
        .onAppear(perform: {
            viewModel.apply(.onAppear)
        })
    }

    @ViewBuilder
    private var KeyboardLayout: some View {
        VStack {
            switch(viewModel.model) {
            case .perKey, .perKeyGS65:
                VStack {
                    ForEach(0..<viewModel.keyboardMap.count) { i in
                        HStack {
                            ForEach(0..<viewModel.keyboardMap[i].count) { j in
                                KeyView(viewModel: viewModel.keyModels.first(where: {
                                    $0.ssKey.region == viewModel.keyboardRegionAndKeyCodes[i][j].0 &&
                                    $0.ssKey.keycode == viewModel.keyboardRegionAndKeyCodes[i][j].1
                                })!)
                                    .frame(width: 60 * viewModel.keyboardMap[i][j],
                                           height: 60)
                            }
                        }
                    }
                }
            default:
                Text("Oops")
            }
        }
        .padding(20)
    }
}

//struct PerKeyKeyboardDeviceView_Preview: PreviewProvider {
//    static var previews: some View {
//        PerKeyKeyboardDeviceView(ssDevice: SSDevice.demo))
//    }
//}
