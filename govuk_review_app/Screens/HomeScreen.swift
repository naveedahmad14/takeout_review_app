//
//  HomeScreen.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 15/01/2025.
//

import SwiftUI
import CoreData
import SVGKit

struct HomeScreen: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = HomeViewModel()
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
                mapToggleButton
            }
            .padding(.horizontal)

            Picker("Pick office", selection: $viewModel.selectedOffice) {
                ForEach(offices, id: \ .self) { office in
                    Text(office).tag(office)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(4)
        }
    }

    // MARK: - Takeouts List
    private var takeoutsList: some View {
        List(viewModel.filteredTakeouts) { takeout in
            NavigationLink(destination: ReviewsScreen(takeout: takeout)) {
                VStack(alignment: .leading) {
                    if !takeout.imageDataArray.isEmpty {
                        imageGallery(for: takeout)
                    }
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

    // MARK: - Image Gallery
    private func imageGallery(for takeout: TakeoutEntity) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(takeout.imageDataArray.compactMap { UIImage(data: $0) }, id: \ .self) { uiImage in
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 100)
                        .clipped()
                        .cornerRadius(10)
                }
            }
            .padding(.vertical, 5)
        }
    }

    // MARK: - Map/List Toggle Button
    private var mapToggleButton: some View {
        Picker("", selection: $showMapView) {
            Text("List").tag(false)
            Text("Map").tag(true)
        }
        .pickerStyle(SegmentedPickerStyle())
        .frame(width: 120)
    }

    // MARK: - AI Chat Button
    private var aiChatButton: some View {
        HStack {
            Spacer()
            NavigationLink(destination: AIChatScreen()) {
                Text("Chat for AI recommendations")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 350)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding(.bottom, 5)
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                header
                VStack(alignment: .leading) {
                    officePicker
                    if showMapView {
                        MapView(takeouts: viewModel.filteredTakeouts, selectedOffice: viewModel.selectedOffice)
                            .frame(height: 400)
                            .cornerRadius(10)
                    } else {
                        takeoutsList
                    }
                    Spacer()
                }
                .onAppear { viewModel.fetchTakeouts() }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 0.5)
                )
                aiChatButton
            }
            .padding(20)
        }
    }
}
