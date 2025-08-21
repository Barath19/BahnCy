import AppIntents

struct BahnCyShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: VoiceConversationIntent(),
            phrases: [
                "Start voice conversation with \(.applicationName)",
                "Talk to \(.applicationName)",
                "Voice chat with \(.applicationName)",
                "Start talking to \(.applicationName)"
            ],
            shortTitle: "Voice Chat",
            systemImageName: "waveform"
        )
    }
}