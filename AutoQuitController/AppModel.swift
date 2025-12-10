//
//  AppModel.swift
//  AutoQuitController
//
//  Data models and state management
//

import Foundation
import AppKit
import Combine

// MARK: - Schedule Model
struct AppSchedule: Identifiable, Codable {
    var id = UUID()
    var appBundleId: String
    var appName: String
    var quitTime: Date
    var isEnabled: Bool
    var repeatDays: Set<Int> // 0 = Sunday, 1 = Monday, etc.
    var warningMinutes: Int // Minutes before quit to show warning
    var isOneTime: Bool // If true, schedule is deleted after execution
    
    init(appBundleId: String, appName: String, quitTime: Date, isEnabled: Bool = true, repeatDays: Set<Int> = [], warningMinutes: Int = 5, isOneTime: Bool = false) {
        self.appBundleId = appBundleId
        self.appName = appName
        self.quitTime = quitTime
        self.isEnabled = isEnabled
        self.repeatDays = repeatDays
        self.warningMinutes = warningMinutes
        self.isOneTime = isOneTime
    }
}

// MARK: - Quit Log Entry
struct QuitLogEntry: Identifiable, Codable {
    var id = UUID()
    var appName: String
    var appBundleId: String
    var quitTime: Date
    var wasSuccessful: Bool
}

// MARK: - App Model
class AppModel: ObservableObject {
    @Published var schedules: [AppSchedule] = []
    @Published var quitLogs: [QuitLogEntry] = []
    @Published var whitelistedApps: Set<String> = []
    @Published var isPaused: Bool = false
    @Published var showNotifications: Bool = true
    
    private let schedulesKey = "com.tipsio239.AutoQuitController.schedules"
    private let logsKey = "com.tipsio239.AutoQuitController.logs"
    private let whitelistKey = "com.tipsio239.AutoQuitController.whitelist"
    private let settingsKey = "com.tipsio239.AutoQuitController.settings"
    
    init() {
        loadData()
    }
    
    // MARK: - Data Persistence
    func saveSchedules() {
        if let encoded = try? JSONEncoder().encode(schedules) {
            UserDefaults.standard.set(encoded, forKey: schedulesKey)
        }
    }
    
    func loadSchedules() {
        if let data = UserDefaults.standard.data(forKey: schedulesKey),
           let decoded = try? JSONDecoder().decode([AppSchedule].self, from: data) {
            schedules = decoded
        }
    }
    
    func saveLogs() {
        // Keep only last 100 logs
        let logsToSave = Array(quitLogs.suffix(100))
        if let encoded = try? JSONEncoder().encode(logsToSave) {
            UserDefaults.standard.set(encoded, forKey: logsKey)
        }
    }
    
    func loadLogs() {
        if let data = UserDefaults.standard.data(forKey: logsKey),
           let decoded = try? JSONDecoder().decode([QuitLogEntry].self, from: data) {
            quitLogs = decoded
        }
    }
    
    func saveWhitelist() {
        UserDefaults.standard.set(Array(whitelistedApps), forKey: whitelistKey)
    }
    
    func loadWhitelist() {
        if let array = UserDefaults.standard.array(forKey: whitelistKey) as? [String] {
            whitelistedApps = Set(array)
        }
    }
    
    func saveSettings() {
        UserDefaults.standard.set(isPaused, forKey: "\(settingsKey).isPaused")
        UserDefaults.standard.set(showNotifications, forKey: "\(settingsKey).showNotifications")
    }
    
    func loadSettings() {
        isPaused = UserDefaults.standard.bool(forKey: "\(settingsKey).isPaused")
        showNotifications = UserDefaults.standard.bool(forKey: "\(settingsKey).showNotifications")
    }
    
    func loadData() {
        loadSchedules()
        loadLogs()
        loadWhitelist()
        loadSettings()
    }
    
    // MARK: - Schedule Management
    func addSchedule(_ schedule: AppSchedule) {
        schedules.append(schedule)
        saveSchedules()
    }
    
    func updateSchedule(_ schedule: AppSchedule) {
        if let index = schedules.firstIndex(where: { $0.id == schedule.id }) {
            schedules[index] = schedule
            saveSchedules()
        }
    }
    
    func deleteSchedule(_ schedule: AppSchedule) {
        schedules.removeAll { $0.id == schedule.id }
        saveSchedules()
    }
    
    func toggleSchedule(_ schedule: AppSchedule) {
        if let index = schedules.firstIndex(where: { $0.id == schedule.id }) {
            schedules[index].isEnabled.toggle()
            saveSchedules()
        }
    }
    
    // MARK: - Logging
    func addLogEntry(appName: String, appBundleId: String, wasSuccessful: Bool) {
        let entry = QuitLogEntry(
            appName: appName,
            appBundleId: appBundleId,
            quitTime: Date(),
            wasSuccessful: wasSuccessful
        )
        quitLogs.insert(entry, at: 0)
        saveLogs()
    }
    
    func clearLogs() {
        quitLogs.removeAll()
        saveLogs()
    }
    
    // MARK: - Whitelist Management
    func addToWhitelist(_ bundleId: String) {
        whitelistedApps.insert(bundleId)
        saveWhitelist()
    }
    
    func removeFromWhitelist(_ bundleId: String) {
        whitelistedApps.remove(bundleId)
        saveWhitelist()
    }
    
    func isWhitelisted(_ bundleId: String) -> Bool {
        return whitelistedApps.contains(bundleId)
    }
    
    // MARK: - Settings
    func togglePause() {
        isPaused.toggle()
        saveSettings()
    }
    
    func toggleNotifications() {
        showNotifications.toggle()
        saveSettings()
    }
}

// MARK: - Running App Info
struct RunningApp: Identifiable {
    let id: String
    let bundleId: String
    let name: String
    let icon: NSImage?
    
    init(bundleId: String, name: String, icon: NSImage?) {
        self.id = bundleId
        self.bundleId = bundleId
        self.name = name
        self.icon = icon
    }
}

extension AppModel {
    func getRunningApps() -> [RunningApp] {
        let workspace = NSWorkspace.shared
        let runningApps = workspace.runningApplications
        
        return runningApps
            .filter { app in
                // Filter out system apps and this app itself
                guard let bundleId = app.bundleIdentifier,
                      bundleId != "com.tipsio239.AutoQuitController",
                      app.activationPolicy == .regular else {
                    return false
                }
                return true
            }
            .map { app in
                RunningApp(
                    bundleId: app.bundleIdentifier ?? "",
                    name: app.localizedName ?? "Unknown",
                    icon: app.icon
                )
            }
            .sorted { $0.name < $1.name }
    }
}

