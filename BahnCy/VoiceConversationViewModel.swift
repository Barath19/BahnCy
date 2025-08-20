import SwiftUI
import Combine
import ElevenLabs

// Temporary message structure until we can use the real ElevenLabs Message
struct VoiceMessage {
    let content: String
    let role: MessageRole
    let timestamp = Date()
}

enum MessageRole {
    case user
    case assistant
}

@MainActor
class VoiceConversationViewModel: ObservableObject {
    @Published var messages: [VoiceMessage] = []
    @Published var isConnected = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isMuted = false
    @Published var agentIsSpeaking = false
    
    private var conversation: Conversation?
    private var cancellables = Set<AnyCancellable>()
    
    func startConversation(agentId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Create voice conversation configuration (not text-only)
            let config = ConversationConfig()
            
            conversation = try await ElevenLabs.startConversation(
                agentId: agentId,
                config: config
            )
            
            setupConversationObservers()
            
        } catch {
            errorMessage = "Failed to start voice conversation: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    private func setupConversationObservers() {
        guard let conversation = conversation else { return }
        
        // TODO: Connect to real ElevenLabs message stream
        // For now, messages are managed locally
        
        // Initially set connected state
        isLoading = false
        isConnected = true
    }
    
    private func handleStatusChange(_ status: Any) {
        // Handle different connection states
        // Note: Actual status enum values need to be determined from SDK
        isConnected = true
        isLoading = false
    }
    
    func endConversation() async {
        await conversation?.endConversation()
        conversation = nil
        isConnected = false
        messages.removeAll()
        cancellables.removeAll()
    }
    
    func toggleMute() {
        Task {
            do {
                if isMuted {
                    try? await conversation?.setMuted(false)
                } else {
                    try? await conversation?.setMuted(true)
                }
                
                await MainActor.run {
                    isMuted.toggle()
                }
            }
        }
    }
    
    func sendTextMessage(_ content: String) {
        // For now, just print - replace with correct SDK method
        print("Would send text message: \(content)")
        
        // Add message to local array for UI
        let userMessage = VoiceMessage(content: content, role: .user)
        messages.append(userMessage)
        
        // Simulate AI response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let aiMessage = VoiceMessage(content: "I heard you say: '\(content)'. In a real implementation, this would be the AI's voice response.", role: .assistant)
            self.messages.append(aiMessage)
        }
    }
}

// Extension for VoiceMessage to work with our UI
extension VoiceMessage {
    var isFromUser: Bool {
        return role == .user
    }
    
    var displayContent: String {
        return content
    }
}