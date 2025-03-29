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
    let persistenceController: PersistenceController

    init() {
        GMSServices.provideAPIKey("YOUR_API_KEY")
        GMSPlacesClient.provideAPIKey("YOUR_API_KEY")

        GooglePlacesService.shared.initialize()

        let persistence = PersistenceController.shared
        self.persistenceController = persistence

        DispatchQueue.main.async {
            persistence.addData()
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeScreen()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
