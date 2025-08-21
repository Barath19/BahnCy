# BahnCy - AI Voice Agent for Berlin 🚇🐻
![IMG_F087B0158526-1](https://github.com/user-attachments/assets/b877a5fa-34ce-4e51-bfb0-ee1e03aea7c3)

![BahnCy Demo](https://img.shields.io/badge/iOS-17%2B-blue) ![Swift](https://img.shields.io/badge/Swift-5.9-orange) ![License](https://img.shields.io/badge/License-MIT-green)

## 🌟 Features

- **🎙️ Voice AI Conversations** - Powered by ElevenLabs Conversational AI
- **🌐 3D Visual Feedback** - Spline-powered sphere animations that respond to voice activity
- **⚡ App Intents Integration** - Quick access via Shortcuts and Siri
- **📱 Dual Interface** - Full app experience + lightweight modal for shortcuts
- **🎨 Real-time Animations** - Sphere scales based on agent speaking states
- **🚇 Transport Intelligence** - Berlin public transport information via AI agent

## 🎯 Demo

 **📹 Watch the Demo:** [BahnCy in Action](https://youtu.be/s9hk1tRZDp8)

**Try the AI Agent:** [Talk to BahnCy Agent](https://elevenlabs.io/app/conversational-ai/talk-to/agent_4301k204f3fgfgmte77ezfxznqkz)

## 🛠 Tech Stack

### Frontend
- **iOS**: SwiftUI, App Intents
- **Voice AI**: [ElevenLabs Swift SDK](https://github.com/elevenlabs/elevenlabs-swift-sdk)
- **3D Graphics**: SplineRuntime

### Backend & Integration
- **Backend**: Cloudflare Workers (generated via [Fiberplane](https://fiberplane.com/codegen/-DBEu7MoryAYyHzjIawjT/attachments/v1?tab=code&file=src%2Findex.ts))
- **Transport API**: [VBB Transport REST API](https://v6.vbb.transport.rest/api.html)
- **Automation**: [Zapier MCP](https://mcp.zapier.com/mcp/servers/297b6761-df63-4909-814f-40e8c360c301/config) for Telegram integration

## 🚀 Getting Started

### Prerequisites

- Xcode 15+
- iOS 17+
- ElevenLabs API key
- Spline account (for 3D scene customization)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/BahnCy.git
   cd BahnCy
   ```

2. **Configure ElevenLabs API**
   ```swift
   // In VoiceConversationViewModel.swift
   private let apiKey = "your_elevenlabs_api_key_here"
   ```

3. **Set up Spline 3D Scene**
   - Create a scene at [spline.design](https://spline.design)
   - Add a sphere object named "Sphere"
   - Create states:
     - **"speaking"** → normal scale (1.0)  
     - **"idle"** → smaller scale (0.8)
   - Add events:
     - **Mouse Hover** → transition to "speaking" state
     - **Mouse Up** → transition to "idle" state
   - Export and update URL in `ContentView.swift`

4. **Build and Run**
   ```bash
   open BahnCy.xcodeproj
   # Build and run in Xcode
   ```

## 📱 Usage

### Main App Experience
1. **Launch BahnCy** - See the 3D animated sphere
2. **Tap "Start Voice Chat"** - Begin AI conversation
3. **Watch Animations** - Sphere responds to voice activity
4. **Ask Questions** - Get Berlin transport information
5. **End Conversation** - Return to idle state

### Quick Access via Shortcuts
1. **Add to Shortcuts** - Automatically available after first launch
2. **Use Siri** - Say "Start voice conversation with BahnCy"
3. **Modal Interface** - Lightweight overlay with single button
4. **Voice Indicator** - Shows real-time speaking status

## 🎨 Architecture

```
BahnCy/
├── BahnCy/
│   ├── ContentView.swift              # Main app with 3D scene
│   ├── VoiceConversationViewModel.swift # ElevenLabs integration
│   ├── VoiceStateManager.swift        # Shared state management  
│   ├── VoiceConversationIntent.swift  # App Intent modal
│   ├── AppShortcuts.swift            # Siri shortcuts config
│   └── BahnCyApp.swift               # App entry point
```

### Key Components

- **VoiceStateManager** - Singleton managing voice states across app and intent
- **SplineController** - Handles 3D animation event triggers  
- **App Intent** - Provides quick access via Shortcuts/Siri
- **ElevenLabs SDK** - Real-time voice conversation processing

## 🌐 Backend Integration

### Cloudflare Worker
- Serverless backend handling transport API requests
- Generated using **Fiberplane** for rapid development
- Provides real-time VBB Berlin transport data to AI agent

### Telegram Integration  
- **Zapier MCP** server for automated notifications
- Cross-platform communication and updates
- Seamless workflow automation

## 🤖 AI Agent Capabilities

The BahnCy agent can:
- 🚇 Provide Berlin public transport information (BVG, S-Bahn, U-Bahn)
- 🗺️ Give directions and route planning
- ⏰ Share real-time departure information
- 🎯 Answer travel-related questions
- 💬 Engage in natural conversation about Berlin

## ⚙️ Configuration

### Customizing the Voice Agent
```swift
// Change agent ID to use your own ElevenLabs agent
@Parameter(title: "Agent ID", default: "your_agent_id_here")
var agentId: String
```

### 3D Animation Settings
```swift
// Adjust animation triggers in ContentView.swift
if voiceState.isAgentSpeaking {
    splineController.emitEvent(.mouseHover, nameOrUUID: "Sphere") // Normal size
} else {
    splineController.emitEvent(.mouseUp, nameOrUUID: "Sphere")    // Smaller size  
}
```

### UI Customization
```swift
// Modal gradient colors in VoiceConversationIntent.swift
LinearGradient(
    colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.6)],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

## 🔧 Development

### Building from Source
```bash
# Clone repository
git clone https://github.com/yourusername/BahnCy.git
cd BahnCy

# Open in Xcode
open BahnCy.xcodeproj

# Add your ElevenLabs API key
# Configure Spline scene URL
# Build and run
```

### Testing App Intents
1. Build and install app on device
2. Open **Shortcuts** app
3. Look for "Start Voice Conversation" 
4. Test via Shortcuts or Siri voice commands
