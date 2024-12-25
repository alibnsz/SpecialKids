//
//  SpeacialKidsApp.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 22.11.2024.
//
import SwiftUI
import FirebaseCore
import FirebaseAppCheck

@main
struct SpecialKids: App {
    @StateObject var firebaseManager = FirebaseManager.shared
    
    init() {
        FirebaseApp.configure()

        #if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        #endif
    }

    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .environmentObject(firebaseManager)
        }
    }
}

