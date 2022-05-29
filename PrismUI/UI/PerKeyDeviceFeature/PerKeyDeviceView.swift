//
//  PerKeyDeviceView.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/19/22.
//

import SwiftUI
import ComposableArchitecture
import PrismClient

struct PerKeyDeviceView: View {
    let store: Store<PerKeyDeviceCore.State, PerKeyDeviceCore.Action>

    var body: some View {
        WithViewStore(store.stateless) { viewStore in
            HStack(alignment: .top, spacing: 24) {
                PerKeySettingsView(
                    store: store.scope(
                        state: \.settingsState,
                        action: PerKeyDeviceCore.Action.perKeySettings
                    )
                )
                    .background(ColorManager.contentOverBackground)
                    .cornerRadius(12)
                    .padding(0)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 0)

                PerKeyKeyboardView(
                    store: store.scope(
                        state: \.keyboardState,
                        action: PerKeyDeviceCore.Action.perKeyKeyboard
                    )
                )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
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
                                viewStore.send(.touchedOutside)
                            }
                    )
            )
            .navigationTitle("SteelSeries KLC")
            .toolbar {
                ToolbarItemGroup {
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

                    // MARK: Mouse mode
                    WithViewStore(store) { viewStore in
                        Picker("", selection: viewStore.binding(\.$mouseMode)) {
                            ForEach(PerKeyDeviceCore.MouseMode.allCases, id: \.self) { mode in
                                if mode != .rectangle {
                                    Image(systemName: mode.rawValue)
                                }
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            .onAppear {
                viewStore.send(.touchedOutside)
            }

        }
    }
}

struct PerKeyDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        let deviceState = PrismDevice.State.mock(
            identifier: 1,
            name: "PerKeyKeybaord",
            model: .perKeyShort,
            device: HIDCommunicationMock.mock
        )
        PerKeyDeviceView(
            store: .init(
                initialState: .init(
                    device: deviceState
                ),
                reducer: PerKeyDeviceCore.reducer,
                environment: .init(
                    mainQueue: .main,
                    backgroundQueue: .init(
                        DispatchQueue.global(
                            qos: .background
                        )
                    ),
                    perKeyController: .mock(
                        for: deviceState
                    )
                )
            )
        )
    }
}
