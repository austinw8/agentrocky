//
//  ChatView.swift
//  agentrocky
//

import SwiftUI

struct ChatView: View {
    @State private var input: String = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(role: .rocky, text: "Hey! What do you want me to build?")
    ]
    @State private var isRunning = false
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Rocky")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                if isRunning {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            // Message history
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(messages) { msg in
                            MessageBubble(message: msg)
                        }
                    }
                    .padding(10)
                    .id("bottom")
                }
                .onChange(of: messages.count) { _ in
                    withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                }
            }

            Divider()

            // Input row
            HStack(spacing: 8) {
                TextField("Ask Rocky...", text: $input, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...4)
                    .focused($inputFocused)
                    .onSubmit { sendMessage() }
                    .padding(8)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(input.isEmpty || isRunning ? .secondary : .accentColor)
                }
                .buttonStyle(.plain)
                .disabled(input.isEmpty || isRunning)
            }
            .padding(10)
        }
        .onAppear { inputFocused = true }
    }

    private func sendMessage() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isRunning else { return }

        messages.append(ChatMessage(role: .user, text: trimmed))
        input = ""
        isRunning = true

        Task {
            let output = await ClaudeRunner.run(prompt: trimmed)
            await MainActor.run {
                messages.append(ChatMessage(role: .rocky, text: output))
                isRunning = false
            }
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            if message.role == .rocky {
                Text("🤖")
                    .font(.caption)
                    .padding(.top, 2)
            } else {
                Spacer()
            }

            Text(message.text)
                .font(.system(size: 13))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(message.role == .user
                    ? Color.accentColor.opacity(0.15)
                    : Color(NSColor.controlBackgroundColor))
                .cornerRadius(10)
                .textSelection(.enabled)

            if message.role == .user {
                Text("👤")
                    .font(.caption)
                    .padding(.top, 2)
            } else {
                Spacer()
            }
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: Role
    let text: String

    enum Role { case user, rocky }
}
