//
//  govuk_review_appApp.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 15/01/2025.
//

import SwiftUI

@main
struct govuk_review_appApp: App {
    let persistenceController = PersistenceController.shared

    init() {
            persistenceController.addMockData() // Add mock data when app launches
        }
    
    var body: some Scene {
        WindowGroup {
            HomeScreen()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
