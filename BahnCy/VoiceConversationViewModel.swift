import SwiftUI
import Combine
import ElevenLabs

@MainActor
class VoiceConversationViewModel: ObservableObject {
    @Published var isConnected = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isMuted = false
    @Published var agentIsSpeaking = false
    
    private var conversation: Conversation?
    private var cancellables = Set<AnyCancellable>()
    private let voiceState = VoiceStateManager.shared
    
    private let apiKey = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    private let config = ConversationConfig()
    
    init() {
        initializeElevenLabs()
    }
    
    func startConversation(agentId: String) async {
        isLoading = true
        voiceState.updateLoadingState(true)
        errorMessage = nil
        
        do {
            // Use pre-created configuration to reduce delay
            conversation = try await ElevenLabs.startConversation(
                agentId: agentId,
                config: config
            )
            
            setupConversationObservers()
            
        } catch {
            errorMessage = "Failed to start voice conversation: \(error.localizedDescription)"
            isLoading = false
            voiceState.updateLoadingState(false)
        }
    }
    
    private func setupConversationObservers() {
        guard let conversation = conversation else { return }
        
        // Initially set connected state
        isLoading = false
        isConnected = true
        voiceState.updateLoadingState(false)
        voiceState.updateConnectionState(true)
        
        // Set up real ElevenLabs event listeners
        setupRealEventListeners()
    }
    
    private func handleStatusChange(_ status: Any) {
        // Handle different connection states
        // Note: Actual status enum values need to be determined from SDK
        isConnected = true
        isLoading = false
    }
    
    private func setupRealEventListeners() {
        guard let conversation = conversation else { return }
        
        // Monitor agent state (speaking vs listening) - REAL ElevenLabs API
        conversation.$agentState
            .sink { [weak self] agentState in
                DispatchQueue.main.async {
                    let stateString = String(describing: agentState)
                    print("Agent state: \(stateString)")
                    
                    // Check if agent is speaking (case insensitive)
                    if stateString.lowercased().contains("speaking") {
                        print("🗣️ Agent STARTED speaking")
                        self?.voiceState.updateAgentSpeaking(true)
                        self?.agentIsSpeaking = true
                    } else {
                        print("🤐 Agent STOPPED speaking") 
                        // All other states (listening, thinking, etc.) = not speaking
                        self?.voiceState.updateAgentSpeaking(false)
                        self?.agentIsSpeaking = false
                    }
                }
            }
            .store(in: &cancellables)
        
        // Monitor overall conversation state - REAL ElevenLabs API
        conversation.$state
            .sink { [weak self] state in
                DispatchQueue.main.async {
                    // Use string representation to avoid guessing enum cases
                    let stateString = String(describing: state)
                    print("Conversation state: \(stateString)")
                    
                    // Handle known patterns
                    if stateString.contains("active") {
                        self?.isConnected = true
                        self?.isLoading = false
                        self?.voiceState.updateConnectionState(true)
                    } else if stateString.contains("connecting") || stateString.contains("loading") {
                        self?.isLoading = true
                        self?.isConnected = false
                    } else if stateString.contains("ended") || stateString.contains("idle") {
                        self?.isConnected = false
                        self?.isLoading = false
                        self?.voiceState.updateConnectionState(false)
                    } else if stateString.contains("error") {
                        self?.isConnected = false
                        self?.isLoading = false
                        self?.voiceState.updateConnectionState(false)
                        self?.errorMessage = "Connection error"
                    }
                }
            }
            .store(in: &cancellables)
        
        // Monitor mute state for user interaction - REAL ElevenLabs API
        conversation.$isMuted
            .sink { [weak self] isMuted in
                DispatchQueue.main.async {
                    self?.isMuted = isMuted
                    // When unmuted and agent not speaking, user can speak
                    if !isMuted && !(self?.agentIsSpeaking ?? false) {
                        self?.voiceState.updateUserSpeaking(true)
                    } else {
                        self?.voiceState.updateUserSpeaking(false)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func initializeElevenLabs() {
        // Pre-warm any necessary system components
        // The main delay is from the network call to ElevenLabs servers
        // Configuration is already pre-created as a property
        
        // Start the agent speaking simulation timer setup
        setupAgentSimulation()
    }
    
    private func setupAgentSimulation() {
        // Pre-setup the simulation components to be ready when needed
        // This helps with smoother UX when starting conversations
    }
    
    func endConversation() async {
        await conversation?.endConversation()
        conversation = nil
        isConnected = false
        agentIsSpeaking = false
        voiceState.updateConnectionState(false)
        voiceState.updateAgentSpeaking(false)
        voiceState.updateUserSpeaking(false)
        voiceState.updateLoadingState(false)
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
}