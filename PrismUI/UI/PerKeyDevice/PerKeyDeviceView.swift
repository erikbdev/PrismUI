//
//  PerKeyKeyboardView.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/17/21.
//

import SwiftUI
import PrismKit

struct PerKeyDeviceView: View {
    @StateObject var viewModel: PerKeyDeviceViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 24) {
            KeySettingsView(viewModel: viewModel.output.keySettingsViewModel)
                .background(ColorManager.contentOverBackground)
                .cornerRadius(12)
                .padding(0)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 0)

            PerKeyKeyboardView(
                model: viewModel.output.model,
                items: viewModel.output.keys,
                selectionCallback: viewModel.input.selectionTrigger.send,
                selected: viewModel.output.selected
            )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    TapGesture()
                        .onEnded({ _ in
                            withAnimation {
                                viewModel.input.touchedOutsideTriger.send()
                            }
                        })
                )
                .gesture(
                    DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
                        .onChanged({ value in
                            viewModel.input.draggedOutsideTrigger.send((start: value.startLocation, current: value.location))
                        })
                        .onEnded({ value in
                            viewModel.input.draggedOutsideTrigger.send((start: value.startLocation, current: value.location))
                        })
                )
        }
        .padding(24)
        .fixedSize()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Rectangle()
                .fill(Color.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    TapGesture()
                        .onEnded { _ in
                            viewModel.input.touchedOutsideTriger.send()
                        }
                )
        )
        .navigationTitle(viewModel.output.name)
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
                Picker("", selection: viewModel.input.mouseMode) {
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
            viewModel.input.appearedTrigger.send()
        })
    }
}
