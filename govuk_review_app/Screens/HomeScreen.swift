//
//  HomeScreen.swift
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
    @State private var showMapView = false
    let offices = ["London", "Manchester", "Bristol"]

    // MARK: - Header
    private var header: some View {
        Image("logo")
            .resizable()
            .scaledToFit()
            .frame(width: 600)
    }

    // MARK: - Office Picker
    private var officePicker: some View {
        VStack(alignment: .leading, spacing: -8) {
            HStack {
                Text("Pick office")
                    .font(.system(size: 24, weight: .semibold))

                Spacer()
                menuButton
            }
            .padding(.horizontal)

            Picker("Pick office", selection: $viewModel.selectedOffice) {
                ForEach(offices, id: \ .self) { office in
                    Text(office)
                        .font(.title)
                        .tag(office)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(4)
        }
    }

    // MARK: - Takeouts List
    private var takeoutsPicker: some View {
        List(viewModel.filteredTakeouts) { takeout in
            NavigationLink(destination: ReviewsScreen(takeout: takeout)) {
                VStack(alignment: .leading) {
                    if !takeout.localImageNames.filter({ UIImage(named: $0) != nil }).isEmpty {
                        imageGallery(for: takeout)
                    }
                    //Text(takeout.name ?? "")
                    Text(takeout.name)
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

    // MARK: - Image Gallery
    private func imageGallery(for takeout: Takeout) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(takeout.localImageNames, id: \ .self) { imageName in
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 100)
                        .clipped()
                        .cornerRadius(10)
                    /*
                    // API Image Loading (Commented Out for Now)
                    if !takeout.imageUrlsArray.isEmpty {
                        ForEach(takeout.imageUrlsArray, id: \.self) { imageURL in
                            AsyncImage(url: URL(string: imageURL)) { image in
                                image.resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 100)
                                    .clipped()
                                    .cornerRadius(10)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                    */
                }
            }
            .padding(.vertical, 5)
        }
    }

    // MARK: - Delete Data Button
//        private var deleteTakeouts: some View {
//            Button(action: {
//                PersistenceController.shared.deleteAllReviews()
//                viewModel.fetchTakeouts()
//            }) {
//                Text("Delete Mock Data")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.red)
//                    .cornerRadius(10)
//            }
//        }

    // MARK: - Map/List Button
    private var menuButton: some View {
        Picker("", selection: $showMapView) {
            Text("List").tag(false)
            Text("Map").tag(true)
        }
        .pickerStyle(SegmentedPickerStyle()) // Makes it a toggle-style switch
        .frame(width: 120) // Adjust width as needed
    }

        // MARK: - Body
        var body: some View {
            NavigationView {
                VStack {
                    header
                    HStack {
                        VStack(alignment: .leading, spacing: -8) {
                            officePicker
                            if showMapView {
                                MapView(takeouts: viewModel.filteredTakeouts)
                                    .frame(height: 400)
                                    .cornerRadius(10)
                            } else {
                                takeoutsPicker
                            }
                            //deleteTakeouts
                            Spacer()
                        }
                        .onAppear { viewModel.fetchTakeouts() }
                        .padding(.leading, -15)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .frame(height: 600)
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
