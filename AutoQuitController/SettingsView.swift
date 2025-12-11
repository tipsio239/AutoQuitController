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
            VStack(alignment: .leading, spacing: 6) {
                Text("Logs")
                    .font(.title2.weight(.semibold))
                Text("Review recent quit activity and manage log history.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Quit Logs")
                    .font(.headline)

                if appModel.quitLogs.isEmpty {
                    Text("No quit logs yet")
                        .foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(appModel.quitLogs.prefix(50)) { log in
                            LogRowView(log: log)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .frame(height: 300)

                    Button("Clear Logs") {
                        appModel.clearLogs()
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(.red)
                }
            }
            .padding(12)
            .background(Color(nsColor: .textBackgroundColor))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
        }
        .padding(20)
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

