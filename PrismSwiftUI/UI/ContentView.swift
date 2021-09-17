//
//  ContentView.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/16/21.
//

import SwiftUI
import PrismKit

struct ContentView: View {
    @ObservedObject var manager = PrismDriver.shared

    var body: some View {
        NavigationView {
            DevicesView(devices: $manager.devices)
            Text("Welcome")
        }
        .onAppear {
            manager.start()
        }
        .onDisappear {
            manager.stop()
        }.toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: { // 1
                    Image(systemName: "sidebar.leading")
                })
            }
        }
    }

    private func toggleSidebar() { // 2
        #if os(iOS)
        #else
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
