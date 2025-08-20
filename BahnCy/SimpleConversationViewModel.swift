import SwiftUI
import Combine

struct SimpleMessage {
    let content: String
    let isFromUser: Bool
    let timestamp = Date()
}

@MainActor
class SimpleConversationViewModel: ObservableObject {
    @Published var messages: [SimpleMessage] = []
    @Published var isConnected = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isMuted = false
    
    func startConversation(agentId: String) async {
        isLoading = true
        errorMessage = nil
        
        // Simulate connection delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        isConnected = true
        isLoading = false
        
        // Add welcome message
        messages.append(SimpleMessage(content: "Hello! I'm your AI assistant. How can I help you today?", isFromUser: false))
    }
    
    func endConversation() async {
        isConnected = false
        messages.removeAll()
    }
    
    func toggleMute() {
        isMuted.toggle()
    }
    
    func sendMessage(_ content: String) {
        // Add user message
        messages.append(SimpleMessage(content: content, isFromUser: true))
        
        // Simulate AI response after a delay
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            await MainActor.run {
                let responses = [
                    "That's interesting! Tell me more.",
                    "I understand. How can I assist you with that?",
                    "Great question! Let me help you with that.",
                    "I see what you mean. Would you like me to explain further?",
                    "That's a good point. What would you like to know next?"
                ]
                
                let randomResponse = responses.randomElement() ?? "Thank you for sharing that with me."
                messages.append(SimpleMessage(content: randomResponse, isFromUser: false))
            }
        }
    }
}