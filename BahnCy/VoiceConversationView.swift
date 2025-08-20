import SwiftUI
import ElevenLabs

struct VoiceConversationView: View {
    @StateObject private var viewModel = VoiceConversationViewModel()
    @State private var agentId = ""
    @State private var messageText = ""
    @State private var showingAgentIdAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                if !viewModel.isConnected && !viewModel.isLoading {
                    startConversationView
                } else {
                    voiceConversationView
                }
            }
            .navigationTitle("Voice AI Chat")
            .alert("Enter Agent ID", isPresented: $showingAgentIdAlert) {
                TextField("Agent ID", text: $agentId)
                Button("Start Voice Chat") {
                    Task {
                        await viewModel.startConversation(agentId: agentId)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Please enter your ElevenLabs Agent ID to start a voice conversation.")
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
        VStack(spacing: 24) {
            // Voice-focused icon
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.blue)
                .symbolEffect(.pulse)
            
            VStack(spacing: 12) {
                Text("Start Voice AI Chat")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Talk naturally with your AI assistant")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("• Speak and the AI will respond with voice\n• Natural conversation flow\n• Real-time audio streaming")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                TextField("Enter Agent ID", text: $agentId)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                Button("🎤 Start Voice Conversation") {
                    if agentId.isEmpty {
                        showingAgentIdAlert = true
                    } else {
                        Task {
                            await viewModel.startConversation(agentId: agentId)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)
                .font(.headline)
            }
            
            if viewModel.isLoading {
                HStack {
                    ProgressView()
                    Text("Connecting to voice AI...")
                }
                .padding()
            }
        }
        .padding(32)
    }
    
    private var voiceConversationView: some View {
        VStack(spacing: 0) {
            voiceConversationHeader
            messagesList
            voiceControlsView
        }
    }
    
    private var voiceConversationHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Circle()
                        .fill(viewModel.isConnected ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    
                    Text(viewModel.isConnected ? "Voice AI Connected" : "Disconnected")
                        .font(.headline)
                        .foregroundColor(viewModel.isConnected ? .green : .red)
                }
                
                Text("Speak naturally or type messages")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("End Call") {
                Task {
                    await viewModel.endConversation()
                }
            }
            .buttonStyle(.bordered)
            .foregroundColor(.red)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    if viewModel.messages.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "mic.circle")
                                .font(.system(size: 48))
                                .foregroundColor(.blue.opacity(0.6))
                            
                            Text("Start speaking or type a message below")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Text("Your voice conversation will appear here")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(40)
                    } else {
                        ForEach(viewModel.messages.indices, id: \.self) { index in
                            let message = viewModel.messages[index]
                            VoiceMessageBubble(message: message)
                                .id(index)
                        }
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
    
    private var voiceControlsView: some View {
        VStack(spacing: 16) {
            // Voice activity indicator
            HStack {
                Image(systemName: viewModel.isMuted ? "mic.slash.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(viewModel.isMuted ? .red : .blue)
                
                Text(viewModel.isMuted ? "Muted" : "Listening")
                    .font(.headline)
                    .foregroundColor(viewModel.isMuted ? .red : .blue)
                
                Spacer()
                
                Button(action: viewModel.toggleMute) {
                    Image(systemName: viewModel.isMuted ? "mic.slash.fill" : "mic.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(viewModel.isMuted ? Color.red : Color.blue)
                        .clipShape(Circle())
                }
            }
            
            // Text input as backup
            HStack {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                
                Button("Send") {
                    if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        viewModel.sendTextMessage(messageText)
                        messageText = ""
                    }
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !viewModel.isConnected)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

struct VoiceMessageBubble: View {
    let message: VoiceMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                HStack {
                    if !message.isFromUser {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.blue)
                    }
                    
                    Text(message.displayContent)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(message.isFromUser ? Color.blue : Color(.systemGray5))
                        )
                        .foregroundColor(message.isFromUser ? .white : .primary)
                    
                    if message.isFromUser {
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                Text(message.isFromUser ? "You" : "AI Assistant")
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
    VoiceConversationView()
}