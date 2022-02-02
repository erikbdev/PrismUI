//
//  PerKeyKeyboardView.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/17/21.
//

import SwiftUI
import PrismKit


struct PerKeyDeviceView: View {
    @StateObject private var viewModel: PerKeyDeviceViewModel

    init (ssDevice: SSDevice) {
        let viewModel = PerKeyDeviceViewModel(ssDevice: ssDevice)
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            // Background Click touch
            Rectangle()
                .fill(Color.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    TapGesture()
                        .onEnded({ _ in
                            withAnimation {
                                viewModel.apply(.onTouchOutside)
                            }
                        })
                )

            // Main View

            HStack(alignment: .top, spacing: 24) {
                KeySettingsView(viewModel: viewModel.keySettingsViewModel)
                    .background(ColorManager.contentOverBackground)
                    .cornerRadius(12)
                    .padding(0)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 0)

                    KeyboardLayout
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .gesture(
                            TapGesture()
                                .onEnded({ _ in
                                    withAnimation {
                                        viewModel.apply(.onTouchOutside)
                                    }
                                })
                        )
                        .gesture(
                            DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
                                .onChanged({ value in
                                    viewModel.apply(.onDragOutside(start: value.startLocation, currentPoint: value.location))
                                })
                                .onEnded({ value in
                                    viewModel.apply(.onDragOutside(start: .zero, currentPoint: .zero))
                                })
                        )
                        .overlay(
                            Rectangle()
                                .strokeBorder(style: StrokeStyle(lineWidth: 2))
                                .frame(width: viewModel.dragSelectionRect.width,
                                       height: viewModel.dragSelectionRect.height)
                                .position(x: viewModel.dragSelectionRect.origin.x,
                                          y: viewModel.dragSelectionRect.origin.y)
                        )
            }
            .padding(24)
            .fixedSize()

            if viewModel.modalActive {
                
            }
        }
        .navigationTitle(viewModel.ssDevice.name)
        .toolbar {
            ToolbarItemGroup {
                // Presets
                Picker("", selection: .constant(0)) {
                    Text("Preset 1").tag(0)
                    Text("Preset 2").tag(1)
                    Text("Preset 3").tag(2)
                    Text("Preset 4").tag(3)
                    Text("Preset 5").tag(4)
                }
                .pickerStyle(.menu)
                .labelsHidden()

                Spacer()
                Picker("", selection: $viewModel.mouseMode) {
                    ForEach(PerKeyDeviceViewModel.MouseMode.allCases, id: \.self) { mode in
                        if mode != .rectangle {
                            Image(systemName: mode.rawValue)
                        }
                    }
                }
                .pickerStyle(.segmented)
            }
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
                        }
                    }
                }
            }
        }
        .fixedSize()
    }
}

//struct PerKeyKeyboardDeviceView_Preview: PreviewProvider {
//    static var previews: some View {
//        PerKeyDeviceView(ssDevice: SSDevice.demo))
//    }
//}
