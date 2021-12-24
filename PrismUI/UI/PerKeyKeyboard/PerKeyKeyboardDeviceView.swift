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
        ZStack {
            if viewModel.finishedLoading {
//                HSplitView() {
//                    KeySettingsView(keyModels: [], isPresented: .constant(false)) {
//
//                    }
                    KeyboardLayout
//                }
            } else {
                Text("Loading keys...")
            }
        }
        .cornerRadius(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture(perform: {
            withAnimation {
                viewModel.apply(.onTouchOutside)
            }
        })
        .toolbar {
            Button {
                showingPopover.toggle()
            } label: {
                Image(systemName: "eyedropper.halffull")
            }
            .disabled(viewModel.selected.count == 0)
    
            Picker("", selection: $viewModel.mouseMode) {
                Image(systemName: "cursorarrow").tag(0)
                Image(systemName: "cursorarrow.rays").tag(1)
            }
            .pickerStyle(.segmented)
        }
        .onAppear(perform: {
            viewModel.apply(.onAppear)
        })
        .sheet(isPresented: $showingPopover, content: {
            KeySettingsView(keyModels: viewModel.selected, isPresented: $showingPopover) {
                viewModel.apply(.onSubmit)
            }
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
