//
//  AIChatScreen.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 15/01/2025.
//

import Foundation
import SwiftUI

struct AIChatScreen: View {
    @State private var messages: [ChatMessage] = []
    @State private var userInput: String = ""

    var body: some View {
        VStack {
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                        }
                    }
                    .padding()
                }
                .background(Color.white)
            }

            Divider()

            HStack {
                TextField("Type a message...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading, 8)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("AI Chat")
    }

    private func sendMessage() {
        guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let userMessage = ChatMessage(id: UUID(), text: userInput, isUser: true)
        messages.append(userMessage)
        let currentInput = userInput
        userInput = ""

        generateResponse(for: currentInput)
    }

    private func generateResponse(for userInput: String) {
        guard let url = URL(string: "http://127.0.0.1:8000/recommendations") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let input = userInput.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        let requestBody: [String: [String]] = ["preferences": input]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    messages.append(ChatMessage(id: UUID(), text: "Failed to connect to AI.", isUser: false))
                }
                return
            }

            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let recommendations = jsonResponse?["recommendations"] as? [String], let responseText = recommendations.first {
                    DispatchQueue.main.async {
                        messages.append(ChatMessage(id: UUID(), text: responseText, isUser: false))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    messages.append(ChatMessage(id: UUID(), text: "Invalid response from AI.", isUser: false))
                }
            }
        }.resume()
    }
}

struct ChatMessage: Identifiable {
    let id: UUID
    let text: String
    let isUser: Bool
}

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer() }

            Text(message.text)
                .padding()
                .background(message.isUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(message.isUser ? .white : .black)
                .cornerRadius(15)
                .frame(maxWidth: 250, alignment: message.isUser ? .trailing : .leading)

            if !message.isUser { Spacer() }
        }
    }
}

struct AIChatScreen_Previews: PreviewProvider {
    static var previews: some View {
        AIChatScreen()
    }
}
