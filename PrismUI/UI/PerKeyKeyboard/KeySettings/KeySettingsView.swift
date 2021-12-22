//
//  KeySettingsView.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/17/21.
//

import SwiftUI
import OrderedCollections

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
                    .fill(Color(.tertiaryLabelColor))
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

            ColourPickerView(color: $viewModel.currentColor)
                .disabled(viewModel.disableColorPicker)

            Picker("Mode", selection: $viewModel.mode) {
                Text("Steady").tag(0)
                Text("ColorShift").tag(1)
                Text("Breathing").tag(2)
                Text("Reactive").tag(3)
                Text("Disabled").tag(4)
                if viewModel.mode >= 5 {
                    Text("Mixed").tag(5)
                }
            }

            if viewModel.mode == 1 || viewModel.mode == 2 {
                MultiColorSliderView(colorPositions: .init(
                    [
                        ColorPosition(rgb: .init(red: 0.0, green: 1.0, blue: 0.5), position: 0),
                        ColorPosition(rgb: .init(red: 1.0, green: 1.0, blue: 0.0), position: 0.5),
                        ColorPosition(rgb: .init(red: 1.0, green: 0.0, blue: 1.0), position: 1.0)

                    ]))
                    .frame(height: 26)
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
            .padding()
        }
        .frame(width: 275, height: 450, alignment: .center)
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
