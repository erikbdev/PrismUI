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
    @State var showOriginModal = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading) {
                Text("Effect")
                    .fontWeight(.bold)

                HStack {
                    Picker("Effect", selection: viewModel.input.selectedMode) {
                        ForEach(SSKey.SSKeyModes.allCases, id: \.self) {
                            if $0 == .mixed {
                                if viewModel.output.selectedMode == .mixed {
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

                    if viewModel.output.selectedMode == .steady {
                        RoundedRectangle(cornerRadius: 8)
                            .modifier(PopUpColorPicker(hsb: viewModel.input.steadyColor))
                            .frame(width: 56, height: 28)
                    }
                }
            }

            if viewModel.output.selectedMode == .reactive {
                VStack(alignment: .leading) {
                    // Active colors
                    HStack {
                        RoundedRectangle(cornerRadius: 8)
                            .modifier(PopUpColorPicker(hsb: viewModel.input.activeColor))
                            .frame(width: 56, height: 28)

                        Text("Active Color")
                    }

                    HStack {
                        // Resting Color
                        RoundedRectangle(cornerRadius: 8)
                            .modifier(PopUpColorPicker(hsb: viewModel.input.restColor))
                            .frame(width: 56, height: 28)

                        Text("Rest Color")
                    }
                }
            }

            // Multi Slider
            if viewModel.output.selectedMode == .colorShift || viewModel.output.selectedMode == .breathing {
                MultiColorSlider(selectors: viewModel.input.colorSelectors,
                                 backgroundType: viewModel.input.gradientSliderMode)
                    .frame(height: 48)
            }

            // Speed Slider

            if viewModel.output.selectedMode == .colorShift || viewModel.output.selectedMode == .breathing || viewModel.output.selectedMode == .reactive {
                Slider(value: viewModel.input.speed, in: viewModel.output.speedRange, label: {
                    Text("Speed")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                })
            }

            if viewModel.output.selectedMode == .colorShift {
                Toggle("Wave Mode", isOn: viewModel.input.waveActive.animation())
                    .font(.system(size: 12, weight: .bold, design: .rounded))

                if viewModel.output.waveActive {
                    Button(action: {
                        viewModel.input.showOriginTrigger.send()
                    }){
                        Text("Set Origin")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
//                    .disabled(!viewModel.output.waveActive)

                    // Wave Direction

                    Picker("Direction", selection: viewModel.input.waveDirection) {
                        ForEach(SSKeyEffect.SSPerKeyDirection.allCases, id: \.self) {
                            Text($0.description)
                        }
                    }
                    .font(.system(size: 12, weight: .bold, design: .default))
                    .pickerStyle(.radioGroup)
//                    .disabled(!viewModel.input.waveActive)

                    // Wave Control

                    Picker("Control", selection: viewModel.input.waveControl) {
                        ForEach(SSKeyEffect.SSPerKeyControl.allCases, id: \.self) {
                            Text($0.description)
                        }
                    }
                    .font(.system(size: 12, weight: .bold, design: .default))
                    .pickerStyle(.segmented)
//                    .disabled(!viewModel.input.waveActive)

                    // Pulse

                    Slider(value: viewModel.input.pulse, in: 30...1000, label: {
                        Text("Pulse")
                            .fontWeight(.bold)
                    })
//                        .disabled(!viewModel.input.waveActive)
                }
            }
        }
        .frame(width: 300)
        .padding()
        .onAppear(perform: {
//            viewModel.apply(.onAppear)
        })
        .animation(.linear(duration: 0.15), value: viewModel.output.selectedMode)
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
//            KeySettingsView(viewModel: .init(keyModels: [], updateDevice: {}))
//                .previewLayout(.sizeThatFits)
        }
    }
}
