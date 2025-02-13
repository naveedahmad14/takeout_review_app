import SwiftUI

struct AddReviewScreen: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss // To close the screen after submitting

    var takeout: TakeoutEntity // The takeout being reviewed

    @State private var reviewerName: String = ""
    @State private var reviewText: String = ""
    @State private var rating: Double = 3.0 // Default rating

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Your name (optional)", text: $reviewerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                VStack(alignment: .leading) {
                    Text("Rating: \(String(format: "%.1f", rating)) ⭐️")
                    Slider(value: $rating, in: 1...5, step: 0.5)
                        .padding(.horizontal)
                }

                TextEditor(text: $reviewText)
                    .frame(height: 150)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal)

                Button(action: submitReview) {
                    Text("Add Review ➜")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
            .navigationTitle("Add Review")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func submitReview() {
        let newReview = ReviewEntity(context: viewContext)
        newReview.reviewerName = reviewerName
        newReview.reviewDescription = reviewText
        newReview.rating = rating
        newReview.takeout = takeout

        do {
            try viewContext.save()
            dismiss() // Close screen after saving
        } catch {
            print("Error saving review: \(error)")
        }
    }
}
