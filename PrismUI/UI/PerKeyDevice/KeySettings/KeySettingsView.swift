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
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading) {
                Text("Effect")
                    .fontWeight(.bold)

                HStack {
                    Picker("Effect", selection: $viewModel.selectedMode.animation(.linear(duration: 0.15))) {
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
                    .controlSize(.large)
                    .labelsHidden()

                    if viewModel.selectedMode == .steady {
                        RoundedRectangle(cornerRadius: 8)
                            .modifier(PopUpColorPicker(hsb: $viewModel.steadyColor))
                            .frame(width: 56, height: 28)
                    }
                }
            }

            if viewModel.selectedMode == .reactive {
                VStack(alignment: .leading) {
                    // Active colors
                    HStack {
                        RoundedRectangle(cornerRadius: 8)
                            .modifier(PopUpColorPicker(hsb: $viewModel.activeColor))
                            .frame(width: 56, height: 28)

                        Text("Active Color")
                    }

                    HStack {
                        // Resting Color
                        RoundedRectangle(cornerRadius: 8)
                            .modifier(PopUpColorPicker(hsb: $viewModel.restColor))
                            .frame(width: 56, height: 28)

                        Text("Rest Color")
                    }
                }
            }

            // Multi Slider
            if viewModel.selectedMode == .colorShift || viewModel.selectedMode == .breathing {
                MultiColorSlider(selectors: $viewModel.colorSelectors,
                                 backgroundType: $viewModel.gradientSliderMode)
                    .frame(height: 48)
            }

            // Speed Slider

            if viewModel.selectedMode == .colorShift || viewModel.selectedMode == .breathing || viewModel.selectedMode == .reactive {
                Slider(value: $viewModel.speed, in: viewModel.speedRange, label: {
                    Text("Speed")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                })
            }

            if viewModel.selectedMode == .colorShift {
                Toggle("Wave Mode", isOn: $viewModel.waveActive.animation())
                    .font(.system(size: 12, weight: .bold, design: .rounded))

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

                    Picker("Direction", selection: $viewModel.waveDirection) {
                        ForEach(SSKeyEffect.SSPerKeyDirection.allCases, id: \.self) {
                            Text($0.description)
                        }
                    }
                    .font(.system(size: 12, weight: .bold, design: .default))
                    .pickerStyle(.radioGroup)
                    .disabled(!viewModel.waveActive)

                    // Wave Control

                    Picker("Control", selection: $viewModel.waveControl) {
                        ForEach(SSKeyEffect.SSPerKeyControl.allCases, id: \.self) {
                            Text($0.description)
                        }
                    }
                    .font(.system(size: 12, weight: .bold, design: .default))
                    .pickerStyle(.segmented)
                    .disabled(!viewModel.waveActive)

                    // Pulse

                    Slider(value: $viewModel.pulse, in: 30...1000, label: {
                        Text("Pulse")
                            .fontWeight(.bold)
                    })
                        .disabled(!viewModel.waveActive)
                }
            }
        }
        .frame(width: 300)
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
