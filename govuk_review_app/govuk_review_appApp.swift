//
//  govuk_review_appApp.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 15/01/2025.
//

import SwiftUI
import GoogleMaps
import GooglePlaces

@main
struct govuk_review_appApp: App {
    let persistenceController = PersistenceController.shared

    init() {
            GMSServices.provideAPIKey("AIzaSyC3YyhL4sC5fWp59cDn5Ek7IqErZuRdNB4")
            GMSPlacesClient.provideAPIKey("AIzaSyAKWNWlKobef5VQKTApBeirRY2pLirGqjU")
            persistenceController.addData() // Add mock data when app launches
        }
    
    var body: some Scene {
        WindowGroup {
            HomeScreen()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
