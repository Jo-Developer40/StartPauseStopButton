//
//  ContentView.swift
//  Button2
//
//  Created by Juergen Schulz on 27.10.25.
//  Thanks for the template from Akbarshah Jumanazarov on 3/21/24. (KS_LongPressButtpn)
//

import SwiftUI

/// Pages
enum AppView: Hashable {
case demoView
case settingsView
}

/// MainView with NavigationStack and Toolbar
struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var path: [AppView] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                VStack(spacing: 45) {
                    HoldDownButton2(
                        duration: 3,
                        loadingTint: .white.opacity(0.3),
                        statusTextColor: .white,
                        /* Optional parameters
                         statusTexts: [
                            .start: "Start",
                            .pause: "Pause",
                            .stop: "Stop",
                            .ready: "Bereit"
                        ],
                         statusColors: [
                            .start: .green,
                            .pause: .orange,
                            .stop: .red,
                            .ready: .gray
                        ]
                         */
                    ) {
                            EmptyView()
                        }
                }
                .navigationTitle("Hold Down Button")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationButton(path: $path,title: "Button", icon: "chevron.right", destination: .demoView)
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationButton(path: $path,icon: "gearshape", destination: .settingsView)
                    }
                }
                .navigationDestination(for: AppView.self) { view in
                    switch view {
                    case .demoView:
                        DemoView_(path: $path)
                    case .settingsView:
                        SettingsView_(path: $path)
                    }
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

struct DemoView_: View {
    @Binding var path: [AppView]

    var body: some View {
        VStack(spacing: 30) {
            Text("leere Seite für Demo")
                .font(.title2)
                .foregroundColor(.secondary)
           
        }
        .padding()
        .navigationTitle("Demo")
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
        /* Activate button if required
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
         */
    }
}

    

#Preview {
    ContentView()
}

