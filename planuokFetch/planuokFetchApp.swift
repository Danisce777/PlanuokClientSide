//
//  planuokFetchApp.swift
//  planuokFetch
//
//  Created by MacBook on 27/09/2025.
//

import SwiftUI

@main
struct planuokFetchApp: App {
    
    @StateObject private var networkManager = NetworkManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(networkManager)
        }
    }
}
