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
    @State private var showingPopover = false

    init (ssDevice: SSDevice) {
        let viewModel = PerKeyKeyboardDeviceViewModel(ssDevice: ssDevice)
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            if viewModel.finishedLoading {
                KeyboardLayout
            } else {
                Text("Loading keys...")
            }
        }
        .onAppear(perform: {
            viewModel.apply(.onAppear)
        })
        .sheet(isPresented: $showingPopover, content: {
            KeySettings(ssKey: .constant(viewModel.selected.first!))
        })
    }

    @ViewBuilder
    private func KeySettings(ssKey: Binding<SSKey>) -> some View {
        HStack {
            VStack {
                ColourPickerView(color: ssKey.main.hsv)
                    .frame(width: 250, height: 300, alignment: .center)
                Button("Close") {
                    showingPopover.toggle()
                }
            }
        }
        .padding()
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
                                    .frame(width: 50 * viewModel.keyboardMap[i][j],
                                           height: 50)
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
