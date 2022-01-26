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

    var body: some View {
        VStack(alignment: .leading) {
            Text("Effect")
                .fontWeight(.bold)

            Picker("", selection: $viewModel.selectedMode.animation(.linear(duration: 0.15))) {
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
            .pickerStyle(.menu)
            .labelsHidden()

            // Color Picker
            Text("Color Picker")
                .fontWeight(.bold)
            ColourPickerView(color: $viewModel.selectedColor)
                .frame(width: 275, height: 275)
                .disabled(viewModel.disableColorPicker)

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
            }
            
            // Multi Slider
            if viewModel.selectedMode == .colorShift || viewModel.selectedMode == .breathing {
                MultiColorSliderView(selectors: $viewModel.colorSelectors,
                                     selected: $viewModel.thumbSelected,
                                     backgroundType: $viewModel.gradientSliderMode)
                    .frame(height: 44)
                    .padding(.bottom, 8)
            }

            // Speed Slider
            if viewModel.selectedMode == .colorShift || viewModel.selectedMode == .breathing || viewModel.selectedMode == .reactive {
                Text("Speed")
                    .fontWeight(.bold)

                Slider(value: $viewModel.speed, in: viewModel.speedRange)
                    .labelsHidden()
                    .padding(.top, -8)
            }

            if viewModel.selectedMode == .colorShift {
                // Wave Toggle
                HStack {
                    Text("Wave Mode")
                        .fontWeight(.bold)
                    Toggle("Wave Mode", isOn: $viewModel.waveActive.animation())
                        .labelsHidden()
                }

                if viewModel.waveActive {
                    Button(action: {
                        viewModel.apply(.onShowOrigin)
                    }){
                        Text("Set Origin")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .disabled(!viewModel.waveActive)

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
                    Slider(value: $viewModel.pulse, in: 30...1000)
                        .labelsHidden()
                        .disabled(!viewModel.waveActive)
                        .padding(.top, -8)
                }
            }
        }
        .frame(width: 275)
        .padding()
        .onAppear(perform: {
            viewModel.apply(.onAppear)
        })
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
      HStack {
        Spacer()
          configuration.label.foregroundColor(.primary)
        Spacer()
      }
      .padding(8)
      .background(Color.secondary.cornerRadius(8))
    }
}

struct KeySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            KeySettingsView(viewModel: .init(keyModels: [], updateDevice: {}))
                .previewLayout(.sizeThatFits)
        }
    }
}
