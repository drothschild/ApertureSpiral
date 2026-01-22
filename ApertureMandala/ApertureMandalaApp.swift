//
//  ApertureMandalaApp.swift
//  ApertureMandala
//
//  Created by David Rothschild on 1/22/26.
//

import SwiftUI
import CoreData

@main
struct ApertureMandalaApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
