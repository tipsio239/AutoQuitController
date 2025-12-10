//
//  ScheduleView.swift
//  AutoQuitController
//
//  View for managing schedules
//

import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var appModel: AppModel
    @State private var showingAddSchedule = false
    @State private var selectedSchedule: AppSchedule?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Scheduled Quits")
                    .font(.title2.weight(.semibold))
                Text("Organize recurring quits with clean cards and clear sections.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack {
                Spacer()
                Button(action: { showingAddSchedule = true }) {
                    Label("Add Schedule", systemImage: "plus.circle.fill")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 4)
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
            }

            Group {
                if appModel.schedules.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock.badge.questionmark")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No schedules yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Add a schedule to automatically quit apps at specific times")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .padding(.horizontal, 12)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Upcoming")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)

                        List {
                            ForEach(appModel.schedules) { schedule in
                                ScheduleRowView(schedule: schedule)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedSchedule = schedule
                                    }
                                    .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                            }
                            .onDelete(perform: deleteSchedules)
                        }
                        .listStyle(.inset)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 220)
                    }
                    .padding(16)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )
                }
            }
        }
        .padding(20)
        .sheet(isPresented: $showingAddSchedule) {
            AddScheduleView()
                .environmentObject(appModel)
        }
        .sheet(item: $selectedSchedule) { schedule in
            EditScheduleView(schedule: schedule)
                .environmentObject(appModel)
        }
    }
    
    private func deleteSchedules(at offsets: IndexSet) {
        for index in offsets {
            appModel.deleteSchedule(appModel.schedules[index])
        }
    }
}

struct ScheduleRowView: View {
    let schedule: AppSchedule
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        HStack {
            Toggle("", isOn: Binding(
                get: { schedule.isEnabled },
                set: { _ in appModel.toggleSchedule(schedule) }
            ))
            .toggleStyle(.switch)
            .labelsHidden()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(schedule.appName)
                    .font(.headline)
                
                HStack(spacing: 12) {
                    Label(timeString(from: schedule.quitTime), systemImage: "clock")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if !schedule.repeatDays.isEmpty {
                        Label(repeatDaysString(schedule.repeatDays), systemImage: "repeat")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Label("One-time", systemImage: "calendar")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if schedule.warningMinutes > 0 {
                        Label("\(schedule.warningMinutes)m warning", systemImage: "bell")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    if schedule.lockScreen {
                        Label("Lock screen", systemImage: "lock.fill")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if schedule.shutdownComputer {
                        Label("Shutdown", systemImage: "power")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            if appModel.isWhitelisted(schedule.appBundleId) {
                Image(systemName: "shield.checkmark")
                    .foregroundColor(.orange)
                    .help("This app is whitelisted")
            }
        }
        .padding(.vertical, 4)
        .opacity(schedule.isEnabled ? 1.0 : 0.6)
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func repeatDaysString(_ days: Set<Int>) -> String {
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let sortedDays = days.sorted()
        if sortedDays.count == 7 {
            return "Daily"
        } else if sortedDays == [1, 2, 3, 4, 5] {
            return "Weekdays"
        } else if sortedDays == [0, 6] {
            return "Weekends"
        } else {
            return sortedDays.map { dayNames[$0] }.joined(separator: ", ")
        }
    }
}

struct AddScheduleView: View {
    @EnvironmentObject var appModel: AppModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedApp: RunningApp?
    @State private var quitTime = Date()
    @State private var warningMinutes: Int = 5
    @State private var lastWarningMinutes: Int = 5
    @State private var warningsEnabled: Bool = true
    @State private var repeatDays: Set<Int> = []
    @State private var isOneTime = false
    @State private var lockScreen = false
    @State private var shutdownComputer = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("App") {
                    Picker("Select App", selection: $selectedApp) {
                        Text("Choose an app...").tag(nil as RunningApp?)
                        ForEach(appModel.getRunningApps()) { app in
                            HStack {
                                if let icon = app.icon {
                                    Image(nsImage: icon)
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                }
                                Text(app.name)
                            }
                            .tag(app as RunningApp?)
                        }
                    }
                }
                
                Section("Schedule") {
                    DatePicker("Quit Time", selection: $quitTime, displayedComponents: .hourAndMinute)

                    Toggle("One-time schedule", isOn: $isOneTime)

                    if !isOneTime {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Repeat Days")
                                .font(.headline)
                            
                            HStack {
                                DayButton(day: 0, label: "S", selectedDays: $repeatDays)
                                DayButton(day: 1, label: "M", selectedDays: $repeatDays)
                                DayButton(day: 2, label: "T", selectedDays: $repeatDays)
                                DayButton(day: 3, label: "W", selectedDays: $repeatDays)
                                DayButton(day: 4, label: "T", selectedDays: $repeatDays)
                                DayButton(day: 5, label: "F", selectedDays: $repeatDays)
                                DayButton(day: 6, label: "S", selectedDays: $repeatDays)
                            }
                            
                            HStack {
                                Button("Weekdays") {
                                    repeatDays = [1, 2, 3, 4, 5]
                                }
                                Button("Weekends") {
                                    repeatDays = [0, 6]
                                }
                                Button("Daily") {
                                    repeatDays = [0, 1, 2, 3, 4, 5, 6]
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.accentColor)
                        }
                    }
                }
                
                Section("Warning") {
                    Toggle("Enable warning", isOn: $warningsEnabled)
                        .onChange(of: warningsEnabled) { oldValue, newValue in
                            if newValue {
                                let restoredMinutes = lastWarningMinutes > 0 ? lastWarningMinutes : 5
                                warningMinutes = restoredMinutes
                                lastWarningMinutes = restoredMinutes
                            } else {
                                lastWarningMinutes = warningMinutes > 0 ? warningMinutes : (lastWarningMinutes > 0 ? lastWarningMinutes : 5)
                                warningMinutes = 0
                            }
                        }
                        .onChange(of: warningMinutes) { oldValue, newValue in
                            if warningsEnabled && newValue > 0 {
                                lastWarningMinutes = newValue
                            }
                        }

                    if warningsEnabled {
                        HStack(spacing: 8) {
                            Text("Warning minutes before")
                            Stepper(value: $warningMinutes, in: 1...60) {
                                Text("\(warningMinutes)")
                                    .frame(minWidth: 30)
                            }
                            .frame(maxWidth: 100)
                        }
                    } else {
                        Text("No warning will be shown")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Section("Actions") {
                    Toggle("Lock screen when triggered", isOn: $lockScreen)
                    
                    Toggle("Shutdown computer after quitting", isOn: $shutdownComputer)
                    
                    if shutdownComputer {
                        Text("Requires administrator privileges to complete system shutdown.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 20)
                    }
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .navigationTitle("New Schedule")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addSchedule()
                    }
                    .disabled(selectedApp == nil)
                }
            }
        }
        .frame(width: 600, height: 500)
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    private func addSchedule() {
        guard let app = selectedApp else { return }
        
        let schedule = AppSchedule(
            appBundleId: app.bundleId,
            appName: app.name,
            quitTime: quitTime,
            isEnabled: true,
            repeatDays: isOneTime ? [] : repeatDays,
            warningMinutes: warningsEnabled ? warningMinutes : 0,
            isOneTime: isOneTime,
            lockScreen: lockScreen,
            shutdownComputer: shutdownComputer
        )

        appModel.addSchedule(schedule)
        dismiss()
    }
}

struct EditScheduleView: View {
    let schedule: AppSchedule
    @EnvironmentObject var appModel: AppModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedApp: RunningApp?
    @State private var quitTime: Date
    @State private var warningMinutes: Int
    @State private var lastWarningMinutes: Int
    @State private var warningsEnabled: Bool
    @State private var repeatDays: Set<Int>
    @State private var isOneTime: Bool
    @State private var isEnabled: Bool
    @State private var lockScreen: Bool


    @State private var shutdownComputer: Bool
    
    init(schedule: AppSchedule) {
        self.schedule = schedule
        _selectedApp = State(initialValue: RunningApp(bundleId: schedule.appBundleId, name: schedule.appName, icon: nil))
        _quitTime = State(initialValue: schedule.quitTime)
        let initialWarningMinutes = schedule.warningMinutes > 0 ? schedule.warningMinutes : 5
        _warningMinutes = State(initialValue: initialWarningMinutes)
        _lastWarningMinutes = State(initialValue: initialWarningMinutes)
        _warningsEnabled = State(initialValue: schedule.warningMinutes > 0)
        _repeatDays = State(initialValue: schedule.repeatDays)
        _isOneTime = State(initialValue: schedule.isOneTime)
        _isEnabled = State(initialValue: schedule.isEnabled)
        _lockScreen = State(initialValue: schedule.lockScreen)
        _shutdownComputer = State(initialValue: schedule.shutdownComputer)
    }

    var body: some View {
        let runningApps = appModel.getRunningApps()
        let availableApps = availableApps(from: runningApps)

        NavigationStack {
            Form {
                Section("App") {
                    Picker("Select App", selection: $selectedApp) {
                        Text("Choose an app...").tag(nil as RunningApp?)
                        ForEach(availableApps) { app in
                            HStack {
                                if let icon = app.icon {
                                    Image(nsImage: icon)
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                }
                                Text(app.name)
                            }
                            .tag(app as RunningApp?)
                        }
                    }
                    .disabled(runningApps.isEmpty)
                }

                Section("Schedule") {
                    DatePicker("Quit Time", selection: $quitTime, displayedComponents: .hourAndMinute)

                    Toggle("Enabled", isOn: $isEnabled)

                    Toggle("One-time schedule", isOn: $isOneTime)

                    Toggle("Shutdown computer after quitting", isOn: $shutdownComputer)

                    if shutdownComputer {
                        Text("Requires administrator privileges to complete system shutdown.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 20)
                    }

                    if !isOneTime {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Repeat Days")
                                .font(.headline)
                            
                            HStack {
                                DayButton(day: 0, label: "S", selectedDays: $repeatDays)
                                DayButton(day: 1, label: "M", selectedDays: $repeatDays)
                                DayButton(day: 2, label: "T", selectedDays: $repeatDays)
                                DayButton(day: 3, label: "W", selectedDays: $repeatDays)
                                DayButton(day: 4, label: "T", selectedDays: $repeatDays)
                                DayButton(day: 5, label: "F", selectedDays: $repeatDays)
                                DayButton(day: 6, label: "S", selectedDays: $repeatDays)
                            }
                        }
                    }
                }
                
                Section("Warning") {
                    Toggle("Enable warning", isOn: $warningsEnabled)
                        .onChange(of: warningsEnabled) { oldValue, newValue in
                            if newValue {
                                let restoredMinutes = lastWarningMinutes > 0 ? lastWarningMinutes : 5
                                warningMinutes = restoredMinutes
                                lastWarningMinutes = restoredMinutes
                            } else {
                                lastWarningMinutes = warningMinutes > 0 ? warningMinutes : (lastWarningMinutes > 0 ? lastWarningMinutes : 5)
                                warningMinutes = 0
                            }
                        }
                        .onChange(of: warningMinutes) { oldValue, newValue in
                            if warningsEnabled && newValue > 0 {
                                lastWarningMinutes = newValue
                            }
                        }

                    if warningsEnabled {
                        HStack(spacing: 8) {
                            Text("Warning minutes before")
                            Stepper(value: $warningMinutes, in: 1...60) {
                                Text("\(warningMinutes)")
                                    .frame(minWidth: 30)
                            }
                            .frame(maxWidth: 100)
                        }
                    } else {
                        Text("No warning will be shown")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Section("Actions") {
                    Toggle("Lock screen when triggered", isOn: $lockScreen)
                    
                    Toggle("Shutdown computer after quitting", isOn: $shutdownComputer)
                    
                    if shutdownComputer {
                        Text("Requires administrator privileges to complete system shutdown.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 20)
                    }
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .navigationTitle("Edit Schedule")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSchedule()
                    }
                }
            }
        }
        .frame(width: 600, height: 500)
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    private func saveSchedule() {
        var updatedSchedule = schedule
        if let app = selectedApp {
            updatedSchedule.appBundleId = app.bundleId
            updatedSchedule.appName = app.name
        }
        updatedSchedule.quitTime = quitTime
        updatedSchedule.warningMinutes = warningsEnabled ? warningMinutes : 0
        updatedSchedule.repeatDays = isOneTime ? [] : repeatDays
        updatedSchedule.isOneTime = isOneTime
        updatedSchedule.isEnabled = isEnabled
        updatedSchedule.lockScreen = lockScreen

        updatedSchedule.shutdownComputer = shutdownComputer
        
        appModel.updateSchedule(updatedSchedule)
        dismiss()
    }

    private func availableApps(from runningApps: [RunningApp]) -> [RunningApp] {
        var apps = runningApps
        if !apps.contains(where: { $0.bundleId == schedule.appBundleId }) {
            apps.insert(RunningApp(bundleId: schedule.appBundleId, name: schedule.appName, icon: nil), at: 0)
        }
        return apps
    }
}

struct DayButton: View {
    let day: Int
    let label: String
    @Binding var selectedDays: Set<Int>
    
    var isSelected: Bool {
        selectedDays.contains(day)
    }
    
    var body: some View {
        Button(action: {
            if isSelected {
                selectedDays.remove(day)
            } else {
                selectedDays.insert(day)
            }
        }) {
            Text(label)
                .frame(width: 32, height: 32)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

