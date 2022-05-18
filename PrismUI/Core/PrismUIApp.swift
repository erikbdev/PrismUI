//
//  PrismSwiftUIApp.swift
//  PrismSwiftUI
//
//  Created by Erik Bautista on 9/16/21.
//

import ComposableArchitecture
import SwiftUI

@main
struct PrismUIApp: App {
    @StateObject var prismDriverService = PrismDriverService()

    var body: some Scene {
        WindowGroup {
            DevicesView(
                store: .init(
                    initialState: .init(),
                    reducer: .empty,
                    environment: DevicesEnvironment()
                )
            )
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
