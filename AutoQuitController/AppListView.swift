//
//  AppListView.swift
//  AutoQuitController
//
//  View for managing app whitelist
//

import SwiftUI

struct AppListView: View {
    @EnvironmentObject var appModel: AppModel
    @State private var runningApps: [RunningApp] = []
    @State private var searchText = ""
    
    var filteredApps: [RunningApp] {
        if searchText.isEmpty {
            return runningApps
        }
        return runningApps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Running Apps")
                    .font(.title2.weight(.semibold))
                Text("Manage whitelist choices with clear sections and modern cards.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack {
                TextField("Search apps...", text: $searchText)
                    .textFieldStyle(.roundedBorder)

                Button(action: refreshApps) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
            }

            Group {
                if filteredApps.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "app.badge")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No apps found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                } else {
                    List(filteredApps) { app in
                        AppRowView(app: app)
                            .environmentObject(appModel)
                            .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                    }
                    .listStyle(.inset)
                    .scrollContentBackground(.hidden)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(Color(nsColor: .textBackgroundColor))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
        .padding(20)
        .onAppear {
            refreshApps()
        }
    }
    
    private func refreshApps() {
        runningApps = appModel.getRunningApps()
    }
}

struct AppRowView: View {
    let app: RunningApp
    @EnvironmentObject var appModel: AppModel
    
    var isWhitelisted: Bool {
        appModel.isWhitelisted(app.bundleId)
    }
    
    var body: some View {
        HStack {
            if let icon = app.icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 32, height: 32)
            } else {
                Image(systemName: "app")
                    .frame(width: 32, height: 32)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.headline)
                Text(app.bundleId)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: toggleWhitelist) {
                Label(
                    isWhitelisted ? "Whitelisted" : "Whitelist",
                    systemImage: isWhitelisted ? "shield.checkmark.fill" : "shield"
                )
            }
            .buttonStyle(.borderedProminent)
            .tint(isWhitelisted ? .orange : .accentColor)
        }
        .padding(.vertical, 4)
    }
    
    private func toggleWhitelist() {
        if isWhitelisted {
            appModel.removeFromWhitelist(app.bundleId)
        } else {
            appModel.addToWhitelist(app.bundleId)
        }
    }
}

