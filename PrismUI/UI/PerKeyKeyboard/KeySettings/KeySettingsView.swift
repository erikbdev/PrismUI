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
    @ObservedObject var viewModel: KeySettingsViewModel
    var onSubmit: () -> ()

    init (keyModels: Set<KeyViewModel>,
          onSubmit: @escaping () -> ()) {
        let viewModel = KeySettingsViewModel(keyModels: keyModels)
        _viewModel = .init(wrappedValue: viewModel)
        self.onSubmit = onSubmit
    }

    var body: some View {
        VStack(alignment: .trailing) {
            LazyVStack(alignment: .leading) {
                Section {
                    Text("Effect")
                        .fontWeight(.bold)
    
                    Picker("", selection: $viewModel.currentMode) {
                        ForEach(SSKeyStruct.SSKeyModes.allCases, id: \.self) {
                            if $0 == .mixed {
                                if viewModel.currentMode == .mixed {
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
                    ColourPickerView(color: $viewModel.currentColor)
                        .frame(width: 275, height: 275)
                        .disabled(viewModel.disableColorPicker)
                        .padding(.bottom)

                    if viewModel.currentMode == .reactive {
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
                    if viewModel.currentMode == .colorShift || viewModel.currentMode == .breathing {
                        MultiColorSliderView(selectors: $viewModel.colorSelectors,
                                             selected: $viewModel.thumbSelected,
                                             backgroundType: $viewModel.gradientSliderMode)
                            .frame(height: 26)
                            .padding([.bottom])
                            .padding([.leading, .trailing], 26.0 / 2)
                    }

                    // Speed Slider
                    if viewModel.currentMode == .colorShift || viewModel.currentMode == .breathing || viewModel.currentMode == .reactive {
                        Text("Speed")
                            .fontWeight(.bold)
                            .padding(0.0)
                        Slider(value: $viewModel.speed, in: viewModel.speedRange)
                            .labelsHidden()
                    }

                    if viewModel.currentMode == .colorShift {
                        // Wave Toggle
                        Text("Wave Mode")
                            .fontWeight(.bold)
                        Toggle("Wave Mode", isOn: $viewModel.waveModeOn)
                            .labelsHidden()

                        // Wave Direction
                        Text("Direction")
                            .fontWeight(.bold)
                        Picker("", selection: $viewModel.waveDirection) {
                            ForEach(SSKeyEffectStruct.SSPerKeyDirection.allCases, id: \.self) {
                                Text($0.description)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)

                        // Wave Control
                        Text("Control")
                            .fontWeight(.bold)
                        Picker("", selection: $viewModel.waveControl) {
                            ForEach(SSKeyEffectStruct.SSPerKeyControl.allCases, id: \.self) {
                                Text($0.description)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)

                        // Pulse
                        Text("Pulse")
                            .fontWeight(.bold)
                            .padding(0.0)
                        Slider(value: $viewModel.pulse, in: 30...1000)
                            .labelsHidden()
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
        KeySettingsView(keyModels: [], onSubmit: {})
    }
}
