//
//  ContentView.swift
//  BahnCy
//
//  Created by Bharath Kumar on 20.08.25.
//

import SplineRuntime
import SwiftUI

struct ContentView: View {
    @StateObject private var voiceState = VoiceStateManager.shared
    @StateObject private var viewModel = VoiceConversationViewModel()
    private let splineController = SplineController()
    
    var body: some View {
        // fetching from cloud
        let url = URL(string: "https://build.spline.design/aa8TJMpeXeXGIYAgbAk5/scene.splineswift")!

        // fetching from local
        // let url = Bundle.main.url(forResource: "scene", withExtension: "splineswift")!

        ZStack {
            SplineView(sceneFileURL: url, controller: splineController)
                .ignoresSafeArea(.all)
                .onChange(of: voiceState.isAgentSpeaking) { _, _ in
                    updateSplineAnimation()
                }
            
            // Voice conversation controls overlay
            VStack {
                Spacer()
                
                if viewModel.isConnected {
                    // Connected state - show stop button
                    Button("End Conversation") {
                        Task {
                            await viewModel.endConversation()
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(Color.red)
                    .clipShape(Capsule())
                } else {
                    // Not connected - show start button
                    Button(viewModel.isLoading ? "Connecting..." : "Start Voice Chat") {
                        Task {
                            await viewModel.startConversation(agentId: "agent_4301k204f3fgfgmte77ezfxznqkz")
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(viewModel.isLoading ? Color.gray : Color.green)
                    .clipShape(Capsule())
                    .disabled(viewModel.isLoading)
                }
                
                // Voice state indicator
                if voiceState.isConnected {
                    Text(voiceState.isAgentSpeaking ? "🗣️ Agent Speaking" : 
                         voiceState.isUserSpeaking ? "🎤 User Speaking" : "💭 Listening")
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.regularMaterial)
                        .clipShape(Capsule())
                        .padding(.top, 10)
                }
            }
            .padding(.bottom, 50)
        }
    }
    
    private func updateSplineAnimation() {
        print("🎯 updateSplineAnimation called")
        print("   Agent speaking: \(voiceState.isAgentSpeaking)")
        
        if voiceState.isAgentSpeaking {
            // Agent speaking - trigger mouseHover animation (normal sphere)
            print("   → Triggering mouseHover for agent speaking")
            splineController.emitEvent(.mouseHover, nameOrUUID: "Sphere")
        } else {
            // Agent not speaking - trigger mouseUp animation (smaller sphere)
            print("   → Triggering mouseUp for idle")
            splineController.emitEvent(.mouseUp, nameOrUUID: "Sphere")
        }
    }
}

#Preview {
    ContentView()
}
