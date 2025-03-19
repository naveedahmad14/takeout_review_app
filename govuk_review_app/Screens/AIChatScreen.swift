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
        userInput = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let botResponse = ChatMessage(id: UUID(), text: generateResponse(for: userMessage.text), isUser: false)
            messages.append(botResponse)
        }
    }

    private func generateResponse(for userInput: String) -> String {
        return "This is a placeholder response." // Replace with actual AI response logic
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
