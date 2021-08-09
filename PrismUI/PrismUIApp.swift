//
//  PrismUIApp.swift
//  PrismUI
//
//  Created by Erik Bautista on 8/8/21.
//

import SwiftUI

@main
struct PrismUIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
