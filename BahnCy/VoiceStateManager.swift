import SwiftUI
import Combine

class VoiceStateManager: ObservableObject {
    static let shared = VoiceStateManager()
    
    @Published var isConnected = false
    @Published var isAgentSpeaking = false
    @Published var isUserSpeaking = false
    @Published var isLoading = false
    
    private init() {}
    
    func updateConnectionState(_ connected: Bool) {
        DispatchQueue.main.async {
            self.isConnected = connected
        }
    }
    
    func updateAgentSpeaking(_ speaking: Bool) {
        DispatchQueue.main.async {
            self.isAgentSpeaking = speaking
        }
    }
    
    func updateUserSpeaking(_ speaking: Bool) {
        DispatchQueue.main.async {
            self.isUserSpeaking = speaking
        }
    }
    
    func updateLoadingState(_ loading: Bool) {
        DispatchQueue.main.async {
            self.isLoading = loading
        }
    }
    
    var isAnyoneThinking: Bool {
        isConnected && !isAgentSpeaking && !isUserSpeaking
    }
    
    var isConversationActive: Bool {
        isAgentSpeaking || isUserSpeaking
    }
}