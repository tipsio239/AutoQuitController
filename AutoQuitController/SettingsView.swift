//
//  SettingsView.swift
//  AutoQuitController
//
//  Settings and logs view
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.title2)
                .bold()
            
            Form {
                Section("General") {
                    Toggle("Pause all schedules", isOn: Binding(
                        get: { appModel.isPaused },
                        set: { _ in appModel.togglePause() }
                    ))
                    
                    Toggle("Show notifications", isOn: Binding(
                        get: { appModel.showNotifications },
                        set: { _ in appModel.toggleNotifications() }
                    ))
                }
                
                Section("Quit Logs") {
                    if appModel.quitLogs.isEmpty {
                        Text("No quit logs yet")
                            .foregroundColor(.secondary)
                    } else {
                        List {
                            ForEach(appModel.quitLogs.prefix(50)) { log in
                                LogRowView(log: log)
                            }
                        }
                        .frame(height: 300)
                        
                        Button("Clear Logs") {
                            appModel.clearLogs()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .padding()
    }
}

struct LogRowView: View {
    let log: QuitLogEntry
    
    var body: some View {
        HStack {
            Image(systemName: log.wasSuccessful ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(log.wasSuccessful ? .green : .red)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(log.appName)
                    .font(.headline)
                Text(log.quitTime, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

