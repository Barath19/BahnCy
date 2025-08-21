import AppIntents
import SwiftUI

struct VoiceConversationIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Voice Conversation"
    static var description = IntentDescription("Start a voice conversation with the AI agent")
    
    static var openAppWhenRun: Bool = false
    static var isDiscoverable: Bool = true
    
    @Parameter(title: "Agent ID", default: "agent_4301k204f3fgfgmte77ezfxznqkz")
    var agentId: String
    
    func perform() async throws -> some IntentResult & ShowsSnippetView {
        return .result(
            view: VoiceConversationIntentView(agentId: agentId)
        )
    }
}

extension Notification.Name {
    static let voiceConversationWindowShown = Notification.Name("voiceConversationWindowShown")
}

struct VoiceConversationIntentView: View {
    let agentId: String
    @StateObject private var viewModel = VoiceConversationViewModel()
    @StateObject private var voiceState = VoiceStateManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isPresented = true
    
    var body: some View {
        ZStack {
            // Simple gradient background instead of Spline
            LinearGradient(
                colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .onTapGesture {
                // Only dismiss if not connected to avoid accidental dismissal
                if !viewModel.isConnected && !viewModel.isLoading {
                    dismissModal()
                }
            }
            
            // Main content area - bigger modal
            VStack(spacing: 40) {
                Spacer()
                
                // Voice state indicator - larger
                if viewModel.isConnected {
                    Text(voiceState.isAgentSpeaking ? "🗣️ Agent Speaking" : "🎤 Ready to Talk")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(.regularMaterial)
                        .clipShape(Capsule())
                }
                
                // Main button - much larger
                Button(viewModel.isConnected ? "Stop Talking" : (viewModel.isLoading ? "Connecting..." : "Start Talking")) {
                    if viewModel.isConnected {
                        stopConversation()
                    } else {
                        startConversation()
                    }
                }
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 50)
                .padding(.vertical, 25)
                .background(viewModel.isConnected ? Color.red : (viewModel.isLoading ? Color.gray : Color.green))
                .clipShape(Capsule())
                .disabled(viewModel.isLoading)
                .shadow(radius: 15)
                .scaleEffect(isPresented ? 1.0 : 0.1)
                .opacity(isPresented ? 1.0 : 0.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPresented)
                
                Spacer()
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 60)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
                // Don't dismiss modal on error - let user try again
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private func startConversation() {
        print("🚀 Starting conversation in modal...")
        Task {
            do {
                await viewModel.startConversation(agentId: agentId)
                print("✅ Conversation started successfully")
            } catch {
                print("❌ Conversation failed: \(error)")
            }
        }
    }
    
    private func stopConversation() {
        Task {
            await viewModel.endConversation()
            // Wait a moment for the conversation to properly end
            try? await Task.sleep(nanoseconds: 500_000_000)
            dismissModal()
        }
    }
    
    private func dismissModal() {
        print("🔚 dismissModal() called")
        isPresented = false
        Task {
            if viewModel.isConnected {
                await viewModel.endConversation()
            }
            try? await Task.sleep(nanoseconds: 300_000_000)
            dismiss()
        }
    }
    
}

struct VoiceConversationIntentWindow: View {
    var body: some View {
        VoiceConversationIntentView(agentId: "agent_4301k204f3fgfgmte77ezfxznqkz")
    }
}
