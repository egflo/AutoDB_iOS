//
//  AutoDBApp.swift
//  AutoDB
//
//  Created by Emmanuel Flores on 8/11/22.
//

import SwiftUI

@main
struct AutoDBApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            SearchView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
