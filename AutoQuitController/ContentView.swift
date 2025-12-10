//
//  ContentView.swift
//  AutoQuitController
//
//  Main content view with tab navigation
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appModel: AppModel
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Status bar
            HStack {
                HStack(spacing: 12) {
                    Circle()
                        .fill(appModel.isPaused ? Color.orange : Color.green)
                        .frame(width: 8, height: 8)
                    
                    Text(appModel.isPaused ? "Paused" : "Active")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if !appModel.isPaused {
                        Text("\(appModel.schedules.filter { $0.isEnabled }.count) active schedule\(appModel.schedules.filter { $0.isEnabled }.count == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: { appModel.togglePause() }) {
                    Label(appModel.isPaused ? "Resume" : "Pause", systemImage: appModel.isPaused ? "play.fill" : "pause.fill")
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            // Tab view
            TabView(selection: $selectedTab) {
                ScheduleView()
                    .environmentObject(appModel)
                    .tabItem {
                        Label("Schedules", systemImage: "clock")
                    }
                    .tag(0)
                
                AppListView()
                    .environmentObject(appModel)
                    .tabItem {
                        Label("Apps", systemImage: "app.badge")
                    }
                    .tag(1)
                
                SettingsView()
                    .environmentObject(appModel)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .tag(2)
            }
        }
    }
}
