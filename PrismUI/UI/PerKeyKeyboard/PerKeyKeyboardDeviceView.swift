//
//  PerKeyKeyboardView.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/17/21.
//

import SwiftUI
import PrismKit


struct PerKeyKeyboardDeviceView: View {
    @StateObject private var viewModel: PerKeyKeyboardDeviceViewModel
    @State private var phase: CGFloat = 0

    init (ssDevice: SSDevice) {
        let viewModel = PerKeyKeyboardDeviceViewModel(ssDevice: ssDevice)
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            HStack {
                ScrollView {
                    // Passing down viewmodel rather than recreating it
                    KeySettingsView(viewModel: viewModel.keySettingsViewModel)
                }
                .background(ColorManager.contentOverBackground)
                .cornerRadius(12)
                .padding(24)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 0)

                KeyboardLayout
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: {
                        withAnimation {
                            viewModel.apply(.onTouchOutside)
                        }
                    })
                    .gesture(
                        DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
                            .onChanged({ value in
                                viewModel.containerDragShapeStart = value.startLocation
                                viewModel.containerDragShapeEnd = value.translation
                                
                            })
                            .onEnded({ value in
                                viewModel.containerDragShapeStart = .zero
                                viewModel.containerDragShapeEnd = .zero
                            })
                    )
                // TODO: Add overlay to select multiple by dragging
//                    .overlay(
//                        Rectangle()
//                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10], dashPhase: phase))
//                            .onAppear {
//                                withAnimation(.linear.repeatForever(autoreverses: false)) {
//                                    phase -= 20
//                                }
//                            }
//                            .frame(width: viewModel.containerDragShapeEnd.width + viewModel.containerDragShapeStart.x,
//                                   height: viewModel.containerDragShapeEnd.height + viewModel.containerDragShapeStart.y)
//                            .position(viewModel.containerDragShapeStart)
//                    )
            }
        }
        .navigationTitle(viewModel.ssDevice.name)
        .toolbar {
            ToolbarItemGroup {
                // Presets
//                Picker("", selection: .constant(0)) {
//                    Text("Preset 1").tag(0)
//                    Text("Preset 2").tag(1)
//                    Text("Preset 3").tag(2)
//                    Text("Preset 4").tag(3)
//                    Text("Preset 5").tag(4)
//                }
//                .pickerStyle(.menu)
//                .labelsHidden()

                Spacer()
                Picker("", selection: $viewModel.mouseMode) {
                    ForEach(PerKeyKeyboardDeviceViewModel.MouseMode.allCases, id: \.self) { mode in
                        Image(systemName: mode.rawValue)

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
