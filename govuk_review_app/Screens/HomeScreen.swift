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
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedOffice: String = "Manchester"
    let offices = ["London", "Manchester", "Bristol"]

    var takeoutsPicker: some View {
        List(viewModel.filteredTakeouts) { takeout in
            NavigationLink(destination: ReviewsScreen(takeout: takeout)) {
                VStack(alignment: .leading) {
                    Text(takeout.name ?? "")
                        .font(.headline)
                    Text("⭐ \(String(format: "%.1f", takeout.rating))")
                        .font(.subheadline)
                    Text(takeout.tagline ?? "")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 5)
            }
        }
        .listStyle(PlainListStyle())

    }

    var deleteTakeouts: some View {
        Button(action: {
            PersistenceController.shared.deleteAllData()
            viewModel.fetchTakeouts()
        }) {
            Text("Delete Mock Data")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: -8) {
                        // Office Picker
                        Text("Pick office")
                            .font(.system(size: 24, weight: .semibold))
                            .padding(.leading)

                        Picker("Pick office", selection: $viewModel.selectedOffice) {
                            ForEach(offices, id: \.self) { office in
                                Text(office)
                                    .font(.title)
                                    .tag(office)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(4)
                        //Takeouts Picker
                        takeoutsPicker
                        //deleteTakeouts
                        Spacer()
                    }
                    .onAppear {
                        viewModel.fetchTakeouts()
                    }
                    .padding(.leading, -15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .frame(height: 500)
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 0.5)
                    )
                    Spacer()
                }
            }
            .padding(20)
        }
    }
}
