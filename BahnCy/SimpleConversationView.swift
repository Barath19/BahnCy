import SwiftUI

struct SimpleConversationView: View {
    @StateObject private var viewModel = SimpleConversationViewModel()
    @State private var agentId = "demo-agent"
    @State private var messageText = ""
    @State private var showingAgentIdAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                if !viewModel.isConnected && !viewModel.isLoading {
                    startConversationView
                } else {
                    conversationView
                }
            }
            .navigationTitle("AI Conversation")
            .alert("Enter Agent ID", isPresented: $showingAgentIdAlert) {
                TextField("Agent ID", text: $agentId)
                Button("Start") {
                    Task {
                        await viewModel.startConversation(agentId: agentId)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Please enter your ElevenLabs Agent ID to start the conversation.")
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    private var startConversationView: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Start AI Conversation")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Connect with an AI assistant for a demo conversation")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Start Demo Conversation") {
                Task {
                    await viewModel.startConversation(agentId: agentId)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                ProgressView("Connecting...")
            }
        }
        .padding()
    }
    
    private var conversationView: some View {
        VStack {
            conversationHeader
            messagesList
            messageInputView
        }
    }
    
    private var conversationHeader: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Connected")
                    .font(.headline)
                Text(viewModel.isConnected ? "Demo AI Assistant" : "Disconnected")
                    .font(.caption)
                    .foregroundColor(viewModel.isConnected ? .green : .red)
            }
            
            Spacer()
            
            Button(action: viewModel.toggleMute) {
                Image(systemName: viewModel.isMuted ? "mic.slash.fill" : "mic.fill")
                    .foregroundColor(viewModel.isMuted ? .red : .blue)
            }
            .buttonStyle(.borderedProminent)
            
            Button("End") {
                Task {
                    await viewModel.endConversation()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.messages.indices, id: \.self) { index in
                        let message = viewModel.messages[index]
                        SimpleMessageBubble(message: message)
                            .id(index)
                    }
                }
                .padding()
            }
            .onReceive(viewModel.$messages) { messages in
                if let lastIndex = messages.indices.last {
                    withAnimation {
                        proxy.scrollTo(lastIndex, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private var messageInputView: some View {
        HStack {
            TextField("Type a message...", text: $messageText)
                .textFieldStyle(.roundedBorder)
            
            Button("Send") {
                if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    viewModel.sendMessage(messageText)
                    messageText = ""
                }
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !viewModel.isConnected)
        }
        .padding()
    }
}

struct SimpleMessageBubble: View {
    let message: SimpleMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading) {
                Text(message.content)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(message.isFromUser ? Color.blue : Color(.systemGray5))
                    )
                    .foregroundColor(message.isFromUser ? .white : .primary)
                
                Text(message.isFromUser ? "You" : "AI")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !message.isFromUser {
                Spacer()
            }
        }
    }
}

#Preview {
    SimpleConversationView()
}