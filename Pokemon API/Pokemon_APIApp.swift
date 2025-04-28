//
//  Pokemon_APIApp.swift
//  Pokemon API
//
//  Created by Erik Woods on 4/28/25.
//

import SwiftUI

@main
struct Pokemon_APIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
