//
//  PerKeySettingsView.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/21/22.
//

import SwiftUI
import ComposableArchitecture
import PrismClient

struct PerKeySettingsView: View {
    let store: Store<PerKeySettingsCore.State, PerKeySettingsCore.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                Text("Effect")
                    .fontWeight(.bold)

                HStack {
                    Picker(
                        "Effect",
                        selection: viewStore.binding(\.$mode),
                        content: {
                            ForEach(Key.Effect.Mode.allCases, id: \.self) {
                                if $0 == .mixed {
                                    if viewStore.mode == .mixed {
                                        Text($0.description)
                                    }
                                } else if $0 == .steady && !viewStore.enabled {
                                    Text("Please select a key.")
                                } else {
                                    Text($0.description)
                                }
                            }
                        }
                    )
                        .disabled(!viewStore.enabled)
                        .pickerStyle(.menu)
                        .controlSize(.large)
                        .labelsHidden()
                    
                    if viewStore.mode == .steady && viewStore.enabled {
                        RoundedRectangle(cornerRadius: 8)
                            .modifier(
                                PopUpColorPicker(
                                    hsb: viewStore.binding(\.$steady)
                                )
                            )
                            .frame(width: 56, height: 28)
                            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 4)
                    }
                }

                if viewStore.enabled {
                    if viewStore.mode == .reactive {
                        // Active colors
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .modifier(
                                    PopUpColorPicker(
                                        hsb: viewStore.binding(\.$active)
                                    )
                                )
                                .frame(width: 56, height: 28)
                                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 4)
                            Text("Active Color")
                        }
                        .padding(.top, 4)
                        
                        HStack {
                            // Resting Color
                            RoundedRectangle(cornerRadius: 8)
                                .modifier(
                                    PopUpColorPicker(
                                        hsb: viewStore.binding(\.$rest)
                                    )
                                )
                                .frame(width: 56, height: 28)
                                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 4)
                            Text("Rest Color")
                        }
                    }

                    // Multi Slider

                    if viewStore.mode == .colorShift || viewStore.mode == .breathing {
                        MultiColorSlider(
                            selectors: viewStore.binding(\.$colorSelectors),
                            backgroundStyle: viewStore.binding(\.$gradientStyle)
                        )
                            .frame(height: 48)
                            .padding(.top, 6)
                    }

                    // Speed Slider

                    if viewStore.mode == .colorShift || viewStore.mode == .breathing || viewStore.mode == .reactive {
                        Slider(
                            value: viewStore.binding(\.$speed),
                            in: viewStore.speedRange
                        ) {
                            Text("Speed")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                    }

                    if viewStore.mode == .colorShift {
                        Toggle(
                            "Wave Mode",
                            isOn: viewStore.binding(\.$waveActive)
                        )
                            .font(.system(size: 12, weight: .bold, design: .rounded))

                        if viewStore.waveActive {
                            Button(action: {
                            }){
                                Text("Set Origin")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)

                            // Wave Direction

                            Picker(
                                "Direction",
                                selection: viewStore.binding(\.$direction)
                            ) {
                                ForEach(Key.Effect.Direction.allCases, id: \.self) {
                                    Text($0.description)
                                }
                            }
                            .font(.system(size: 12, weight: .bold, design: .default))
                            .pickerStyle(.radioGroup)

                            //  Wave Control

                            Picker(
                                "Control",
                                selection: viewStore.binding(\.$control)
                            ) {
                                ForEach(Key.Effect.Control.allCases, id: \.self) {
                                    Text($0.description)
                                }
                            }
                            .font(.system(size: 12, weight: .bold, design: .default))
                            .pickerStyle(.segmented)

                            // Pulse

                            Slider(
                                value: viewStore.binding(\.$pulse),
                                in: 30...1000,
                                label: {
                                    Text("Pulse")
                                        .fontWeight(.bold)
                                }
                            )
                        }
                    }
                }
            }
            .frame(width: 300)
            .padding()
            .animation(.linear(duration: 0.15), value: viewStore.mode)
            .animation(.linear(duration: 0.15), value: viewStore.waveActive)
            .animation(.linear(duration: 0.15), value: viewStore.enabled)
        }
    }
}

struct PerKeySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        PerKeySettingsView(
            store: .init(
                initialState: .init(mode: .colorShift),
                reducer: PerKeySettingsCore.reducer,
                environment: .init()
            )
        )
    }
}
