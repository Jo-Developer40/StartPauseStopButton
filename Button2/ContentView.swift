//
//  ContentView.swift
//  Button2
//
//  Created by Juergen Schulz on 27.10.25.
//

import SwiftUI

enum AppView: Hashable {
case startPauseStopButtonView
case settingsView
}

struct ContentView: View {
    @State private var count: Int = 0
    @Environment(\.colorScheme) var colorScheme
    @State private var path: [AppView] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                VStack(spacing: 45) {
                    Text("\(count)")
                        .font(.largeTitle.bold())
                    HoldDownButton2(duration: 2, loadingTint: .white.opacity(0.3)) {
                        EmptyView()
                    }
                }
                .padding()
                
            }
            .navigationTitle("Hold Down Button")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationButton(path: $path,title: "Button", icon: "chevron.right", destination: .startPauseStopButtonView)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                   NavigationButton(path: $path,icon: "gearshape", destination: .settingsView)
                }
            }
            .navigationDestination(for: AppView.self) { view in
                switch view {
                case .startPauseStopButtonView:
                    StartPauseStopButtonView_(path: $path, count: $count)
                case .settingsView:
                    SettingsView_(path: $path)
                }
            }
        }
    }
}

    /// NavigationButton-Hilfsfunktion
struct NavigationButton: View {
    @Binding var path: [AppView]
    
    var title: String? = nil
    var icon: String
    var destination: AppView

    var body: some View {
        Button {
            path.append(destination)
        } label: {
            HStack {
                if let title = title { Text(title) }
                Image(systemName: icon)
            }
        }
    }
}

struct StartPauseStopButtonView_: View {
    @Binding var path: [AppView]
    @Binding var count: Int
    @State private var statusText: String = "Stopped"
    
    var body: some View {
        VStack(spacing: 30) {
            Text("\(count)")
                .font(.largeTitle.bold())
            Text(statusText)
                .font(.title2)
                .foregroundColor(.secondary)
           
        }
        .padding()
        .navigationTitle("Button Demo")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationButton(path: $path, title: "Weiter", icon: "chevron.right", destination: .settingsView)
            }
        }
    }
}
    
struct SettingsView_: View {
    @Binding var path: [AppView]
    
    var body: some View {
        VStack {
            Text("Settings View Content")
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    path.removeAll()
                } label: {
                    HStack {
                        Text("Anfang")
                        Image(systemName: "chevron.right")
                    }
                }
            }
        }
    }
}

    

#Preview {
    ContentView()
}

