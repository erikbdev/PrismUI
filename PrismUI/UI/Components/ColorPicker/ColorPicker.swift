//
//  ColorPicker.swift
//  PrismUI
//
//  Created by Erik Bautista on 1/31/22.
//

import SwiftUI
import Combine

struct ColorPicker: View {
    @Binding var color: HSB
    @State var hexastring = ""
    @State var redString = ""
    @State var greenString = ""
    @State var blueString = ""

    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    ColorBoxView(hsb: $color)
                    ColorHueSlider(hsb: $color)
                        .frame(width: proxy.size.width / 10)
                }

                HStack {
                    Image(systemName: "eyedropper")
                        .font(.system(size: 12, weight: .bold, design: .default))

                    HStack {
                        Text("#")
                            .foregroundColor(.gray)
                            .font(.system(size: 14, weight: .semibold, design: .default))
                        TextField("", text: $hexastring)
                            .textFieldStyle(.plain)
                    }

                    HStack {
                        Text("R")
                            .foregroundColor(.gray)
                            .font(.system(size: 14, weight: .semibold, design: .default))
                        TextField("", text: $redString)
                            .textFieldStyle(.plain)
                            .onReceive(hexastring.publisher.eraseToAnyPublisher()) { newValue in
                                let newValue = newValue.uppercased()
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue {
                                    self.redString = String(filtered.prefix(2))
                                }
                            }
                    }

                    HStack {
                        Text("G")
                            .foregroundColor(.gray)
                            .font(.system(size: 14, weight: .semibold, design: .default))
                        TextField("", text: $greenString)
                            .textFieldStyle(.plain)
                    }

                    HStack {
                        Text("B")
                            .foregroundColor(.gray)
                            .font(.system(size: 14, weight: .semibold, design: .default))
                        TextField("", text: $blueString)
                            .textFieldStyle(.plain)
                    }
                }
            }
        }
    }
}

struct ColorPicker_Previews: PreviewProvider {
    static var previews: some View {
        ColorPicker(color: .constant(.init(hue: 180, saturation: 1.0, brightness: 1.0)))
            .frame(width: 400, height: 240)
    }
}
