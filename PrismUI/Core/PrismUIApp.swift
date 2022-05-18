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
    var body: some Scene {
        WindowGroup {
            DevicesView(
                store: .init(
                    initialState: .init(),
                    reducer: devicesReducer,
                    environment: DevicesEnvironment(
                        devicesManager: .live
                    )
                )
            )
            .background(ColorManager.background) // Main background window
        }
        .windowToolbarStyle(.unified)
        .windowStyle(.titleBar)
        .commands {
            SidebarCommands()
        }
    }
}
