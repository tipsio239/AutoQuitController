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
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Scheduled Quits")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button(action: { showingAddSchedule = true }) {
                    Label("Add Schedule", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
            }
            
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
                .padding(.vertical, 40)
            } else {
                List {
                    ForEach(appModel.schedules) { schedule in
                        ScheduleRowView(schedule: schedule)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedSchedule = schedule
                            }
                    }
                    .onDelete(perform: deleteSchedules)
                }
                .listStyle(.inset)
            }
        }
        .padding()
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
    @State private var repeatDays: Set<Int> = []
    @State private var isOneTime = false
    @State private var shutdownComputer = false
    
    var body: some View {
        NavigationView {
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

                    Toggle("Shutdown computer after quitting", isOn: $shutdownComputer)

                    if shutdownComputer {
                        Text("Requires administrator privileges to complete system shutdown.")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                            .buttonStyle(.bordered)
                        }
                    }
                }
                
                Section("Warning") {
                    Stepper("Warning \(warningMinutes) minutes before", value: $warningMinutes, in: 0...60)
                    if warningMinutes == 0 {
                        Text("No warning will be shown")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("New Schedule")
            .navigationBarTitleDisplayMode(.inline)
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
        .frame(width: 500, height: 500)
    }
    
    private func addSchedule() {
        guard let app = selectedApp else { return }
        
        let schedule = AppSchedule(
            appBundleId: app.bundleId,
            appName: app.name,
            quitTime: quitTime,
            isEnabled: true,
            repeatDays: isOneTime ? [] : repeatDays,
            warningMinutes: warningMinutes,
            isOneTime: isOneTime,
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
    
    @State private var quitTime: Date
    @State private var warningMinutes: Int
    @State private var repeatDays: Set<Int>
    @State private var isOneTime: Bool
    @State private var isEnabled: Bool
    @State private var shutdownComputer: Bool
    
    init(schedule: AppSchedule) {
        self.schedule = schedule
        _quitTime = State(initialValue: schedule.quitTime)
        _warningMinutes = State(initialValue: schedule.warningMinutes)
        _repeatDays = State(initialValue: schedule.repeatDays)
        _isOneTime = State(initialValue: schedule.isOneTime)
        _isEnabled = State(initialValue: schedule.isEnabled)
        _shutdownComputer = State(initialValue: schedule.shutdownComputer)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("App") {
                    HStack {
                        Text(schedule.appName)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
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
                    Stepper("Warning \(warningMinutes) minutes before", value: $warningMinutes, in: 0...60)
                }
            }
            .navigationTitle("Edit Schedule")
            .navigationBarTitleDisplayMode(.inline)
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
        .frame(width: 500, height: 500)
    }
    
    private func saveSchedule() {
        var updatedSchedule = schedule
        updatedSchedule.quitTime = quitTime
        updatedSchedule.warningMinutes = warningMinutes
        updatedSchedule.repeatDays = isOneTime ? [] : repeatDays
        updatedSchedule.isOneTime = isOneTime
        updatedSchedule.isEnabled = isEnabled
        updatedSchedule.shutdownComputer = shutdownComputer
        
        appModel.updateSchedule(updatedSchedule)
        dismiss()
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

