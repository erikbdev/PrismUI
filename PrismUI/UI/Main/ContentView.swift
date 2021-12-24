//
//  ContentView.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/16/21.
//

import SwiftUI
import AppKit
import PrismKit

struct ContentView: View {
    var body: some View {
            NavigationView {
                DevicesView()
                Text("Welcome")
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar, label: { // 1
                        Image(systemName: "sidebar.leading")
                    })
                }
            }
    }

    private func toggleSidebar() { // 2
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
