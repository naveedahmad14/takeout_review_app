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
        // ✅ Ensure API keys are initialized at the very start
        GMSServices.provideAPIKey("AIzaSyC3YyhL4sC5fWp59cDn5Ek7IqErZuRdNB4")
        GMSPlacesClient.provideAPIKey("AIzaSyAKWNWlKobef5VQKTApBeirRY2pLirGqjU")

        // ✅ Delay initialization of services until API key is set
        GooglePlacesService.shared.initialize()

        // ✅ Assign persistenceController to a local variable before using it inside async closure
        let persistence = PersistenceController.shared
        self.persistenceController = persistence

        // ✅ Use local persistence variable inside async closure (No weak reference needed)
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
