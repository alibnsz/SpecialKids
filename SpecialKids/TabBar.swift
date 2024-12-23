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
                    Label("Ana", systemImage: "house")
                }
            
            ClassView()
                .tabItem {
                    Label("Görevler", systemImage: "note.text")
                }
            
            Text("Profili Yönet")
                .tabItem {
                    Label("Profil", systemImage: "person")
                }
        }
        .accentColor(.black)
    }
}

struct ParentTabView: View {
    var body: some View {
        TabView {
            ParentView()
                .tabItem {
                    Label("Ana", systemImage: "house")
                }
            
            ParentView()
                .tabItem {
                    Label("Eğitim", systemImage: "book")
                }
            
            Text("Eğitim İçeriği")
                .tabItem {
                    Label("Eğitim", systemImage: "person")
                }
        }
    }
}

