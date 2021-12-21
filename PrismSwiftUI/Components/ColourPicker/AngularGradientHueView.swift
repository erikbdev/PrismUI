//
//  AngularGradientHueView.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 12/15/21.
//  From https://github.com/Priva28/SwiftUIColourWheel/blob/master/Colour%20Wheel/Views/Experimental/AngularGradientHueView.swift

import SwiftUI

struct AngularGradientHueView: View {
    
    var colours: [Color] = {
        let hue = Array(0...359).reversed()
        return hue.map {
            Color(hue: Double($0) / 359.0, saturation: 1, brightness: 1)
        }
    }()

    var body: some View {
        AngularGradient(gradient: Gradient(colors: colours), center: UnitPoint(x: 0.5, y: 0.5))
            .clipShape(Circle())
    }
}

struct AngularGradientHueView_Previews: PreviewProvider {
    static var previews: some View {
        AngularGradientHueView()
    }
}
