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
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Scheduler Status")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.primary)

                        let activeCount = appModel.schedules.filter { $0.isEnabled }.count
                        Text("\(activeCount) active schedule\(activeCount == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Label("\(appModel.whitelistedApps.count) whitelisted app\(appModel.whitelistedApps.count == 1 ? "" : "s")", systemImage: "shield")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
                            Label("Logs", systemImage: "list.bullet.rectangle")
                        }
                        .tag(2)
                }
                .padding(.horizontal, 8)
                .background(Color(nsColor: .windowBackgroundColor))
            }
        }
    }
}
