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
        ZStack {
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Status bar
                HStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(appModel.isPaused ? Color.orange : Color.green)
                            .frame(width: 10, height: 10)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(appModel.isPaused ? "Paused" : "Active")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.primary)

                            if !appModel.isPaused {
                                Text("\(appModel.schedules.filter { $0.isEnabled }.count) active schedule\(appModel.schedules.filter { $0.isEnabled }.count == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Spacer()

                    Button(action: { appModel.togglePause() }) {
                        Label(appModel.isPaused ? "Resume" : "Pause", systemImage: appModel.isPaused ? "play.fill" : "pause.fill")
                            .frame(minWidth: 110)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(nsColor: .controlBackgroundColor))

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
                .padding(.horizontal, 8)
                .background(Color(nsColor: .windowBackgroundColor))
            }
        }
    }
}
