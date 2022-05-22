//
//  PerKeyDeviceViewComp.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/19/22.
//

import SwiftUI
import ComposableArchitecture
import PrismClient

struct PerKeyDeviceViewComp: View {
    let store: Store<PerKeyDeviceState, PerKeyDeviceAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack(alignment: .top, spacing: 24) {
                PerKeySettingsViewComp(
                    store: store.scope(
                        state: \.settingsState,
                        action: PerKeyDeviceAction.perKeySettings
                    )
                )
                .background(ColorManager.contentOverBackground)
                .cornerRadius(12)
                .padding(0)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 0)

                PerKeyKeyboardViewComp(
                    store: store.scope(
                        state: \.keyboardState,
                        action: PerKeyDeviceAction.perKeyKeyboard
                    )
                )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
//                    .gesture(
//                        TapGesture()
//                            .onEnded({ _ in
//                                withAnimation {
//                                    viewModel.input.touchedOutsideTriger.send()
//                                }
//                            })
//                    )
//                    .gesture(
//                        DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
//                            .onChanged({ value in
//                                viewModel.input.draggedOutsideTrigger.send((start: value.startLocation, current: value.location))
//                            })
//                            .onEnded({ value in
//                                viewModel.input.draggedOutsideTrigger.send((start: value.startLocation, current: value.location))
//                            })
//                    )
            }
            .padding(24)
            .fixedSize()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Rectangle()
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
//                    .gesture(
//                        TapGesture()
//                            .onEnded { _ in
//                                viewModel.input.touchedOutsideTriger.send()
//                            }
//                    )
            )
//            .navigationTitle(viewModel.output.name)
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
//                    Picker("", selection: viewModel.input.mouseMode) {
//                        ForEach(PerKeyDeviceViewModel.MouseMode.allCases, id: \.self) { mode in
//                            if mode != .rectangle {
//                                Image(systemName: mode.rawValue)
//                            }
//                        }
//                    }
//                    .pickerStyle(.segmented)
                }
            }
            .onAppear(perform: {
                viewStore.send(.onAppear)
            })
        }
    }
}

struct PerKeyDeviceViewComp_Previews: PreviewProvider {
    static var previews: some View {
        PerKeyDeviceViewComp(
            store: .init(
                initialState: .init(),
                reducer: perKeyDeviceReducer,
                environment: .init(
                    device: .init(
                        hidDevice: HIDCommunicationMock.mock,
                        id: 0,
                        name: "Device 1",
                        model: .perKey
                    )
                )
            )
        )
    }
}
