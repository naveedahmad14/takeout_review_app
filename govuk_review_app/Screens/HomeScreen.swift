//
//  ContentView.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 15/01/2025.
//

import SwiftUI
import CoreData

struct HomeScreen: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = HomeViewModel() // Attach ViewModel
    @State private var selectedOffice: String = "Manchester" // Default selected office
    let offices = ["London", "Manchester", "Bristol"] // List of offices

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: -8) {
                        // Office Picker
                        Text("Pick office")
                            .font(.system(size: 24, weight: .semibold))
                            .padding(.leading)

                        Picker("Pick office", selection: $viewModel.selectedOffice) { // Directly bind to ViewModel
                            ForEach(offices, id: \.self) { office in
                                Text(office)
                                    .font(.title)
                                    .tag(office)
                            }
                        }
                        .pickerStyle(MenuPickerStyle()) // Dropdown style picker
                        .padding(4)

                        // List of Takeouts
                        List(viewModel.filteredTakeouts) { takeout in
                            NavigationLink(destination: ReviewsScreen(takeout: takeout)) {
                                VStack(alignment: .leading) {
                                    Text(takeout.name)
                                        .font(.headline)
                                    Text("⭐ \(String(format: "%.1f", takeout.rating))")
                                        .font(.subheadline)
                                    Text(takeout.tagline)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        .listStyle(PlainListStyle())

                        Spacer()
                    }
                }
                .padding(.leading, -15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .frame(height: 500) // Explicitly control the total height (adjust as needed)
                .cornerRadius(5) // Rounded corners for content
                .overlay(
                    RoundedRectangle(cornerRadius: 10) // Shape of the border
                        .stroke(Color.gray, lineWidth: 0.5)
                    )
                Spacer()
            }
        }
        .padding(20)
    }

    struct HomeScreen_Previews: PreviewProvider {
        static var previews: some View {
            HomeScreen()
        }
    }
}
