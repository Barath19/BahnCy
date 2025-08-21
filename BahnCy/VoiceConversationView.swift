import SwiftUI
import ElevenLabs

struct VoiceConversationView: View {
    @StateObject private var viewModel = VoiceConversationViewModel()
    @State private var agentId = "agent_4301k204f3fgfgmte77ezfxznqkz"
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Orb animation
            OrbView(
                isConnected: viewModel.isConnected,
                isAgentSpeaking: viewModel.agentIsSpeaking
            )
            .frame(width: 200, height: 200)
            
            // Status text
            Text(viewModel.isConnected ? "Listening..." : "Ready to talk")
                .font(.title2)
                .foregroundColor(viewModel.isConnected ? .green : .primary)
            
            Spacer()
            
            // Control button
            Button(action: {
                Task {
                    if viewModel.isConnected {
                        await viewModel.endConversation()
                    } else {
                        await viewModel.startConversation(agentId: agentId)
                    }
                }
            }) {
                HStack {
                    if viewModel.isConnected {
                        Image(systemName: "phone.down.fill")
                        Text("End Call")
                    } else {
                        Image(systemName: "waveform")
                        Text("Start Voice Chat")
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(viewModel.isConnected ? Color.red : Color.blue)
                .clipShape(Capsule())
            }
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                ProgressView("Connecting...")
                    .padding(.top)
            }
            
            Spacer()
        }
        .padding()
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

struct OrbView: View {
    let isConnected: Bool
    let isAgentSpeaking: Bool
    
    @State private var pulseAnimation: CGFloat = 1.0
    @State private var rotationAnimation: Double = 0
    @State private var glowAnimation: CGFloat = 0.3
    
    var body: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.cyan.opacity(glowAnimation),
                            Color.blue.opacity(glowAnimation * 0.5),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 60,
                        endRadius: 100
                    ),
                    lineWidth: 4
                )
                .scaleEffect(pulseAnimation)
                .opacity(isConnected ? 1.0 : 0.3)
            
            // Main orb
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.9),
                            Color.cyan.opacity(0.8),
                            Color.blue.opacity(0.6),
                            Color.indigo.opacity(0.4)
                        ]),
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 20,
                        endRadius: 80
                    )
                )
                .frame(width: 120, height: 120)
                .shadow(color: Color.cyan.opacity(isAgentSpeaking ? 0.8 : 0.4), radius: isAgentSpeaking ? 20 : 10)
                .scaleEffect(pulseAnimation)
                .rotationEffect(.degrees(rotationAnimation))
                .opacity(isConnected ? 1.0 : 0.5)
            
            // Inner sparkle
            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 8, height: 8)
                .offset(x: -20, y: -20)
                .rotationEffect(.degrees(rotationAnimation * 2))
                .opacity(isConnected ? 1.0 : 0.3)
        }
        .onAppear {
            startAnimations()
        }
        .onChange(of: isAgentSpeaking) { _, _ in
            updateAnimations()
        }
    }
    
    private func startAnimations() {
        // Rotation animation
        withAnimation(
            .linear(duration: 20)
            .repeatForever(autoreverses: false)
        ) {
            rotationAnimation = 360
        }
        
        updateAnimations()
    }
    
    private func updateAnimations() {
        // Pulse animation
        let pulseDuration = isAgentSpeaking ? 0.6 : 1.5
        let pulseScale = isAgentSpeaking ? 1.2 : 1.1
        
        withAnimation(
            .easeInOut(duration: pulseDuration)
            .repeatForever(autoreverses: true)
        ) {
            pulseAnimation = pulseScale
        }
        
        // Glow animation
        let glowIntensity = isAgentSpeaking ? 0.8 : 0.3
        
        withAnimation(
            .easeInOut(duration: pulseDuration)
            .repeatForever(autoreverses: true)
        ) {
            glowAnimation = glowIntensity
        }
    }
}


#Preview {
    VoiceConversationView()
}