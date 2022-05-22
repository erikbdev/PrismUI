//
//  PerKeySettingsViewComp.swift
//  PrismUI
//
//  Created by Erik Bautista on 5/21/22.
//

import SwiftUI
import ComposableArchitecture
import PrismClient

struct PerKeySettingsViewComp: View {
    let store: Store<PerKeySettingsState, PerKeySettingsAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
//            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading) {
                    Text("Effect")
                        .fontWeight(.bold)

                    HStack {
                        Picker(
                            "Effect",
                            selection: viewStore.binding(\.$mode),
                            content: {
                                ForEach(Key.Modes.allCases, id: \.self) {
                                    if $0 == .mixed {
                                        if viewStore.mode == .mixed {
                                            Text($0.description)
                                        }
                                    } else {
                                        Text($0.description)
                                    }
                                }
                            }
                        )
                        .pickerStyle(.menu)
                        .controlSize(.large)
                        .labelsHidden()

                        if viewStore.mode == .steady {
                            RoundedRectangle(cornerRadius: 8)
                                .modifier(
                                    PopUpColorPicker(
                                        hsb: viewStore.binding(\.$steady)
                                    )
                                )
                                .frame(width: 56, height: 28)
                        }
                    }

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
                            Text("Rest Color")
                        }
                    }

                    // Multi Slider

                    if viewStore.mode == .colorShift || viewStore.mode == .breathing {
                        MultiColorSlider(
                            selectors: viewStore.binding(\.$colorSelectors),
                            backgroundType: viewStore.binding(\.$gradientStyle)
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
                                //                            showOriginModal.toggle()
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
                                ForEach(KeyEffect.Direction.allCases, id: \.self) {
                                    Text($0.description)
                                }
                            }
                            .font(.system(size: 12, weight: .bold, design: .default))
                            .pickerStyle(.radioGroup)

                            // Wave Control

                            Picker(
                                "Control",
                                selection: viewStore.binding(\.$control)
                            ) {
                                ForEach(KeyEffect.Control.allCases, id: \.self) {
                                    Text($0.description)
                                }
                            }
                            .font(.system(size: 12, weight: .bold, design: .default))
                            .pickerStyle(.segmented)

                            // Pulse

                            Slider(
                                value: viewStore.binding(\.$pulse),
                                label: {
                                    Text("Pulse")
                                        .fontWeight(.bold)
                                }
                            )
                        }
                    }
                }
                .frame(width: 300)
                .padding()
                .animation(.linear(duration: 0.15), value: viewStore.mode)
                .animation(.linear(duration: 0.15), value: viewStore.waveActive)
            }
        }
//    }
}
    
struct PerKeySettingsViewComp_Previews: PreviewProvider {
    static var previews: some View {
        PerKeySettingsViewComp(
            store: .init(
                initialState: .init(mode: .colorShift),
                reducer: perKeySettingsReducer,
                environment: PerKeySettingsEnvironment()
            )
        )
    }
}
