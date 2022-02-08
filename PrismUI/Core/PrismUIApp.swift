//
//  PrismSwiftUIApp.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/16/21.
//

import SwiftUI

@main
struct PrismUIApp: App {
    let persistenceController = PersistenceController.shared

    @StateObject var prismDriverService = PrismDriverService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(ColorManager.background) // Main background window
                .environmentObject(prismDriverService)
                .onAppear {
                    prismDriverService.startScan()
                }
                .onDisappear {
                    prismDriverService.stopScan()
                }
        }
        .windowToolbarStyle(.unified)
        .windowStyle(.titleBar)
        .commands {
            SidebarCommands()
        }
    }
}
