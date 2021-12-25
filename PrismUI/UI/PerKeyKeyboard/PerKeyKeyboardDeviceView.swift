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
                    .background(ColorManager.contentOverBackground)
                    .cornerRadius(12)
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
        .navigationTitle(viewModel.ssDevice.name)
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
        VStack(spacing: 0) {
            ForEach(0..<viewModel.keyboardMap.count) { i in
                HStack(alignment: .top, spacing: 0) {
                    ForEach(0..<viewModel.keyboardMap[i].count) { j in
                        if let keyViewModel = viewModel.getKeyModelFromGrid(row: i, col: j) {
                            KeyView(viewModel: keyViewModel)
                                .frame(minWidth: viewModel.calcWidthForKey(width: viewModel.keyboardMap[i][j]),
                                       minHeight: viewModel.calcHeightForKeycode(keycode: keyViewModel.ssKey.keycode),
                                       maxHeight: viewModel.calcHeightForKeycode(keycode: keyViewModel.ssKey.keycode))
                                .offset(y: viewModel.calcOffsetForKeycode(row: i, keycode: keyViewModel.ssKey.keycode))
                                .padding(4)

                            // Adds spaces after numpad 3 and 9
                            // so that `.perKey` can look more like the keyboard
                            if viewModel.model == .perKey {
                                if keyViewModel.ssKey.keycode == 0x5A ||
                                    keyViewModel.ssKey.keycode == 0x60 {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(minWidth: viewModel.calcWidthForKey(width: 1.0),
                                               minHeight: viewModel.calcHeightForKeycode(keycode: 0),
                                               maxHeight: viewModel.calcHeightForKeycode(keycode: 0))
                                        .padding(4)
                                }
                            }
                        } else {
                            Rectangle()
                                .frame(minWidth: 60, minHeight: 60, maxHeight: 60)
                        }
                    }
                }
            }
        }
        .fixedSize()
        .padding(40)
    }
}

//struct PerKeyKeyboardDeviceView_Preview: PreviewProvider {
//    static var previews: some View {
//        PerKeyKeyboardDeviceView(ssDevice: SSDevice.demo))
//    }
//}
