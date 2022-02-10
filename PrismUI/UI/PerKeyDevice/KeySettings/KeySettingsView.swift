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
                    Picker("Effect", selection: .init(get: { viewModel.output.selectedMode } , set: { viewModel.input.selectedMode.wrappedValue = $0 })) {
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
                            .modifier(PopUpColorPicker(hsb: .init(get: { viewModel.output.steadyColor }, set: { viewModel.input.steadyColor.wrappedValue = $0 })))
                            .frame(width: 56, height: 28)
                    }
                }
            }

            if viewModel.output.selectedMode == .reactive {
                VStack(alignment: .leading) {
                    // Active colors
                    HStack {
                        RoundedRectangle(cornerRadius: 8)
                            .modifier(PopUpColorPicker(hsb: .init(get: { viewModel.output.activeColor }, set: { viewModel.input.activeColor.wrappedValue = $0 })))
                            .frame(width: 56, height: 28)

                        Text("Active Color")
                    }

                    HStack {
                        // Resting Color
                        RoundedRectangle(cornerRadius: 8)
                            .modifier(PopUpColorPicker(hsb: .init(get: { viewModel.output.restColor }, set: { viewModel.input.restColor.wrappedValue = $0 })))
                            .frame(width: 56, height: 28)

                        Text("Rest Color")
                    }
                }
            }

            // Multi Slider
            if viewModel.output.selectedMode == .colorShift || viewModel.output.selectedMode == .breathing {
                MultiColorSlider(selectors: .init(get: { viewModel.output.colorSelectors }, set: { viewModel.input.colorSelectors.wrappedValue = $0 }),
                                 backgroundType: .init(get: { viewModel.output.gradientStyle }, set: { viewModel.input.gradientStyle.wrappedValue = $0 }))
                    .frame(height: 48)
            }

            // Speed Slider

            if viewModel.output.selectedMode == .colorShift || viewModel.output.selectedMode == .breathing || viewModel.output.selectedMode == .reactive {
                Slider(value: .init(get: { viewModel.output.speed }, set: { viewModel.input.speed.wrappedValue = $0 }), in: viewModel.output.speedRange, label: {
                    Text("Speed")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                })
            }

            if viewModel.output.selectedMode == .colorShift {
                Toggle("Wave Mode", isOn: .init(get: { viewModel.output.waveActive }, set: { viewModel.input.waveActive.wrappedValue = $0 }))
                    .font(.system(size: 12, weight: .bold, design: .rounded))

                if viewModel.output.waveActive {
                    Button(action: {
                        showOriginModal.toggle()
                    }){
                        Text("Set Origin")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)

                    // Wave Direction

                    Picker("Direction", selection: .init(get: { viewModel.output.waveDirection }, set: { viewModel.input.waveDirection.wrappedValue = $0 }) ) {
                        ForEach(SSKeyEffect.SSPerKeyDirection.allCases, id: \.self) {
                            Text($0.description)
                        }
                    }
                    .font(.system(size: 12, weight: .bold, design: .default))
                    .pickerStyle(.radioGroup)

                    // Wave Control

                    Picker("Control", selection: .init(get: { viewModel.output.waveControl }, set: { viewModel.input.waveControl.wrappedValue = $0 }) ) {
                        ForEach(SSKeyEffect.SSPerKeyControl.allCases, id: \.self) {
                            Text($0.description)
                        }
                    }
                    .font(.system(size: 12, weight: .bold, design: .default))
                    .pickerStyle(.segmented)

                    // Pulse

                    Slider(value: .init(get: { viewModel.output.pulse }, set: { viewModel.input.pulse.wrappedValue = $0 }), in: 30...1000, label: {
                        Text("Pulse")
                            .fontWeight(.bold)
                    })
                }
            }
        }
        .frame(width: 300)
        .padding()
        .onAppear(perform: {
            viewModel.input.appearedTrigger.send()
        })
        .animation(.linear(duration: 0.15), value: viewModel.output.selectedMode)
        .animation(.linear(duration: 0.15), value: viewModel.output.waveActive)
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
            KeySettingsView(viewModel: .make(extra: .init()))
        }
    }
}
