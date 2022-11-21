//
//  AutoDBApp.swift
//  AutoDB
//
//

import SwiftUI
import AlertToast

@main
struct AutoDBApp: App {
    let persistenceController = PersistenceController.shared

    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
