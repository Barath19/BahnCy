//
//  ContentView.swift
//  BahnCy
//
//  Created by Bharath Kumar on 20.08.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            VoiceConversationView()
                .tabItem {
                    Image(systemName: "waveform")
                    Text("Voice AI")
                }
            
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Welcome to BahnCy!")
                    .font(.title)
                Text("Your AI-powered conversation app")
                    .foregroundColor(.secondary)
            }
            .padding()
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
        }
    }
}

#Preview {
    ContentView()
}
