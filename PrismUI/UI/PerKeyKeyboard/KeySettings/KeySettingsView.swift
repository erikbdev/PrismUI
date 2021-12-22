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
                Image(systemName: "x.circle.fill")
                    .font(.system(size: 22))
            })
                .buttonStyle(.plain)

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

            HStack {
                if #available(macOS 12.0, *) {
                    Button("Save to Device") {
                        onSubmit()
                        isPresented = false
                    }
                    .disabled(viewModel.disableColorPicker)
                    .controlSize(.large)
                    .buttonStyle(.bordered)
                    .tint(Color.primary)
                } else {
                    Button("Save to Device") {
                        onSubmit()
                        isPresented = false
                    }
                    .disabled(viewModel.disableColorPicker)
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
