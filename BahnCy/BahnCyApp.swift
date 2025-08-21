//
//  BahnCyApp.swift
//  BahnCy
//
//  Created by Bharath Kumar on 20.08.25.
//

import SwiftUI
import AppIntents

@main
struct BahnCyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init() {
        BahnCyShortcuts.updateAppShortcutParameters()
    }
}
