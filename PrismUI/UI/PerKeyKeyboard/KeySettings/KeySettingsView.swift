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
    @Binding var isPresented: Bool
    var onSubmit: () -> ()
    
    init (keyModels: OrderedSet<KeyViewModel>,
          isPresented: Binding<Bool>,
          onSubmit: @escaping () -> ()) {
        let viewModel = KeySettingsViewModel(keyModels: keyModels)
        _isPresented = isPresented
        _viewModel = .init(wrappedValue: viewModel)
        self.onSubmit = onSubmit
    }

    var body: some View {
        VStack(alignment: .trailing) {
            Button(action: {
                isPresented = false
            }, label: {
                Circle()
                    .fill(Color(.init(hue: 0, saturation: 0, brightness: 0.5, alpha: 0.25)))
                    .frame(width: 28, height: 28, alignment: .center)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(.secondary)
                            .frame(width: 28, height: 28, alignment: .center)
                    )
            })
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel(Text("Close"))

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

                    // Multi Slider
                    if viewModel.currentMode == .colorShift || viewModel.currentMode == .breathing {
                        MultiColorSliderView(selectors: $viewModel.colorSelectors,
                                             selected: $viewModel.thumbSelected)
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
                        isPresented = false
                    }
                    .disabled(!viewModel.allowUpdatingDevice)
                    .controlSize(.large)
                    .buttonStyle(.bordered)
                    .tint(Color.primary)
                } else {
                    Button("Save to Device") {
                        onSubmit()
                        isPresented = false
                    }
                    .disabled(!viewModel.allowUpdatingDevice)
                    .controlSize(.large)
                    .buttonStyle(.bordered)
                }
            }
//            .padding()
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
        KeySettingsView(keyModels: [], isPresented: .constant(false), onSubmit: {})
    }
}
