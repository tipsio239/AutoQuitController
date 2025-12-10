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
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Running Apps")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button(action: refreshApps) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
            
            TextField("Search apps...", text: $searchText)
                .textFieldStyle(.roundedBorder)
            
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
                .padding(.vertical, 40)
            } else {
                List(filteredApps) { app in
                    AppRowView(app: app)
                        .environmentObject(appModel)
                }
                .listStyle(.inset)
            }
        }
        .padding()
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
            .buttonStyle(.bordered)
            .tint(isWhitelisted ? .orange : .blue)
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

