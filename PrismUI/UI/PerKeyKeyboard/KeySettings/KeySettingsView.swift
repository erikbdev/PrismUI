//
//  KeySettingsView.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/17/21.
//

import SwiftUI
import OrderedCollections
import PrismKit

struct KeySettingsView: View {
    @StateObject var viewModel: KeySettingsViewModel
    var onSubmit: () -> ()

//    init (onSubmit: @escaping () -> ()) {
//        self.onSubmit = onSubmit
//    }

    var body: some View {
        VStack(alignment: .trailing) {
            LazyVStack(alignment: .leading) {
                Section {
                    Text("Effect")
                        .fontWeight(.bold)
    
                    Picker("", selection: $viewModel.selectedMode) {
                        ForEach(SSKey.SSKeyModes.allCases, id: \.self) {
                            if $0 == .mixed {
                                if viewModel.selectedMode == .mixed {
                                    Text($0.description)
                                }
                            } else {
                                Text($0.description)
                            }
                        }
                    }
                    .labelsHidden()
                    .padding([.bottom])

                    // Color Picker
                    Text("Color Picker")
                        .fontWeight(.bold)
                    ColourPickerView(color: $viewModel.selectedColor)
                        .frame(width: 275, height: 275)
                        .disabled(viewModel.disableColorPicker)
                        .padding(.bottom)

                    if viewModel.selectedMode == .reactive {
                        HStack {
                            // Active colors
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black.opacity(0.50), lineWidth: viewModel.thumbSelected == 0 ? 8 : 0)
                                .background(Color(red: viewModel.activeColor.red,
                                            green: viewModel.activeColor.green,
                                                  blue: viewModel.activeColor.blue)
                                                .cornerRadius(8))
                                .frame(width: 38, height: 38)
                                .onTapGesture {
                                    viewModel.apply(.onReactiveTouch(index: 0))
                                }
                            Text("Active Color")
                                .frame(maxWidth: .infinity)

                            // Resting Color
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black.opacity(0.25), lineWidth: viewModel.thumbSelected == 1 ? 8 : 0)
                                .background(Color(red: viewModel.restColor.red,
                                            green: viewModel.restColor.green,
                                            blue: viewModel.restColor.blue)
                                                .cornerRadius(8))
                                .frame(width: 38, height: 38)
                                .onTapGesture {
                                    viewModel.apply(.onReactiveTouch(index: 1))
                                }

                            Text("Rest Color")
                                .frame(maxWidth: .infinity)
                        }
                        .padding()
                    }

                    // Multi Slider
                    if viewModel.selectedMode == .colorShift || viewModel.selectedMode == .breathing {
                        MultiColorSliderView(selectors: $viewModel.colorSelectors,
                                             selected: $viewModel.thumbSelected,
                                             backgroundType: $viewModel.gradientSliderMode)
                            .frame(height: 26)
                            .padding([.bottom])
                            .padding([.leading, .trailing], 26.0 / 2)
                    }

                    // Speed Slider
                    if viewModel.selectedMode == .colorShift || viewModel.selectedMode == .breathing || viewModel.selectedMode == .reactive {
                        Text("Speed")
                            .fontWeight(.bold)
                            .padding(0.0)
                        Slider(value: $viewModel.speed, in: viewModel.speedRange)
                            .labelsHidden()
                    }

                    if viewModel.selectedMode == .colorShift {
                        // Wave Toggle
                        Text("Wave Mode")
                            .fontWeight(.bold)
                        Toggle("Wave Mode", isOn: $viewModel.waveActive)
                            .labelsHidden()

                        // Wave Direction
                        Text("Direction")
                            .fontWeight(.bold)
                        Picker("", selection: $viewModel.waveDirection) {
                            ForEach(SSKeyEffect.SSPerKeyDirection.allCases, id: \.self) {
                                Text($0.description)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)
                        .disabled(!viewModel.waveActive)

                        // Wave Control
                        Text("Control")
                            .fontWeight(.bold)
                        Picker("", selection: $viewModel.waveControl) {
                            ForEach(SSKeyEffect.SSPerKeyControl.allCases, id: \.self) {
                                Text($0.description)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)
                        .disabled(!viewModel.waveActive)

                        // Pulse
                        Text("Pulse")
                            .fontWeight(.bold)
                            .padding(0.0)
                        Slider(value: $viewModel.pulse, in: 30...1000)
                            .labelsHidden()
                            .disabled(!viewModel.waveActive)
                    }
                }
            }

            HStack {
                if #available(macOS 12.0, *) {
                    Button("Save to Device") {
                        onSubmit()
                    }
                    .disabled(!viewModel.allowUpdatingDevice)
                    .controlSize(.large)
                    .buttonStyle(.bordered)
                    .tint(Color.primary)
                } else {
                    Button("Save to Device") {
                        onSubmit()
                    }
                    .disabled(!viewModel.allowUpdatingDevice)
                    .controlSize(.large)
                    .buttonStyle(.bordered)
                }
            }
        }
        .frame(width: 275, alignment: .center)
        .padding()
        .onAppear(perform: {
            viewModel.apply(.onAppear)
        })
    }
}

struct KeySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        KeySettingsView(viewModel: .init(keyModels: []), onSubmit: {})
    }
}
