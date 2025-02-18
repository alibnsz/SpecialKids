//
//  TabBar.swift
//  SpecialKids
//
//  Created by Mehmet Ali Bunsuz on 24.11.2024.
//


import SwiftUI

struct TeacherTabView: View {
    var body: some View {
        TabView {
            ClassView()
                .tabItem {
                    Label("Ana", systemImage: "house.fill")
                }
            
            CurriculumView()
                .tabItem {
                    Label("Görevler", systemImage: "pencil")
                }
            
            TeacherSettingsView()
                .tabItem {
                    Label("Profil", systemImage: "person")
                }
        }
        .accentColor(.plum)
    }
}

struct ParentTabView: View {
    @State private var pin = ""
    @State private var isVerified = false
    
    var body: some View {
        TabView {
            ParentView()
                .tabItem {
                    Label("Ana", systemImage: "house")
                }
            
            PINVerificationView(pin: $pin, isVerified: $isVerified)
                .tabItem {
                    Label("Oyunlar", systemImage: "gamecontroller")
                }
            
            EducationView()
                .tabItem {
                    Label("Eğitim", systemImage: "book.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Profil", systemImage: "person")
                }
        }
        .accentColor(.plum)
    }
}

