//
//  govuk_review_appApp.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 15/01/2025.
//

import SwiftUI
import GoogleMaps

@main
struct govuk_review_appApp: App {
    let persistenceController = PersistenceController.shared

    init() {
            persistenceController.addMockData() // Add mock data when app launches
            GMSServices.provideAPIKey("AIzaSyCPFVh0MSe34q0IVlIbP9mMEvX2AY5raHU")
        }
    
    var body: some Scene {
        WindowGroup {
            HomeScreen()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
