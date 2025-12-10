//
//  ScheduleService.swift
//  AutoQuitController
//
//  Manages scheduled quit times and triggers
//

import Foundation
import UserNotifications
import Combine

class ScheduleService: ObservableObject {
    static let shared = ScheduleService()
    
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var appModel: AppModel?
    
    private init() {}
    
    func setup(with appModel: AppModel) {
        self.appModel = appModel
        
        // Request notification permissions
        requestNotificationPermission()
        
        // Start checking schedules
        startScheduler()
        
        // Observe schedule changes
        appModel.$schedules
            .sink { [weak self] _ in
                self?.restartScheduler()
            }
            .store(in: &cancellables)
        
        appModel.$isPaused
            .sink { [weak self] _ in
                self?.restartScheduler()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Notification Permission
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Scheduler
    func startScheduler() {
        stopScheduler()
        
        // Check every minute
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.checkSchedules()
        }
        
        // Check immediately
        checkSchedules()
    }
    
    func stopScheduler() {
        timer?.invalidate()
        timer = nil
    }
    
    func restartScheduler() {
        startScheduler()
    }
    
    private func checkSchedules() {
        guard let appModel = appModel else { return }
        guard !appModel.isPaused else { return }
        
        let now = Date()
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: now) - 1 // Convert to 0-6 (Sunday = 0)
        
        for schedule in appModel.schedules {
            guard schedule.isEnabled else { continue }
            guard !appModel.isWhitelisted(schedule.appBundleId) else { continue }
            
            // Check if schedule applies today
            if !schedule.repeatDays.isEmpty && !schedule.repeatDays.contains(currentWeekday) {
                continue
            }
            
            let scheduleTime = schedule.quitTime
            let scheduleComponents = calendar.dateComponents([.hour, .minute], from: scheduleTime)
            let nowComponents = calendar.dateComponents([.hour, .minute], from: now)
            
            // Check if it's time to quit
            if scheduleComponents.hour == nowComponents.hour &&
               scheduleComponents.minute == nowComponents.minute {
                executeQuit(schedule: schedule)
            }
            
            // Check if it's time for warning
            if schedule.warningMinutes > 0 {
                let warningTime = calendar.date(byAdding: .minute, value: -schedule.warningMinutes, to: scheduleTime) ?? scheduleTime
                let warningComponents = calendar.dateComponents([.hour, .minute], from: warningTime)
                
                if warningComponents.hour == nowComponents.hour &&
                   warningComponents.minute == nowComponents.minute {
                    sendWarning(schedule: schedule)
                }
            }
        }
    }
    
    // MARK: - Quit Execution
    private func executeQuit(schedule: AppSchedule) {
        guard let appModel = appModel else { return }

        let success = QuitManager.shared.forceQuitApp(
            bundleId: schedule.appBundleId,
            appName: schedule.appName
        )
        
        appModel.addLogEntry(
            appName: schedule.appName,
            appBundleId: schedule.appBundleId,
            wasSuccessful: success
        )
        
        // Send notification
        if appModel.showNotifications {
            sendQuitNotification(appName: schedule.appName, success: success)
        }

        if schedule.lockScreen {
            triggerLockScreen()
        }

        // Delete one-time schedules
        if schedule.isOneTime {
            appModel.deleteSchedule(schedule)
        }
    }

    private func triggerLockScreen() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self else { return }
            // Try pmset first to immediately sleep the display and lock the session
            if runLockCommand([
                "/usr/bin/pmset",
                "displaysleepnow"
            ]) {
                return
            }

            // Fallback to CGSession to request a lock screen via loginwindow
            _ = runLockCommand([
                "/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession",
                "-suspend"
            ])
        }
    }

    @discardableResult
    private func runLockCommand(_ command: [String]) -> Bool {
        guard let executable = command.first else { return false }

        let task = Process()
        task.executableURL = URL(fileURLWithPath: executable)
        task.arguments = Array(command.dropFirst())

        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            print("Lock screen command failed: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Notifications
    private func sendWarning(schedule: AppSchedule) {
        guard let appModel = appModel else { return }
        guard appModel.showNotifications else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "App Quit Warning"
        content.body = "\(schedule.appName) will be force quit in \(schedule.warningMinutes) minute(s)."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "warning-\(schedule.id.uuidString)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func sendQuitNotification(appName: String, success: Bool) {
        let content = UNMutableNotificationContent()
        content.title = success ? "App Quit" : "Quit Failed"
        content.body = success ? "\(appName) has been force quit." : "Failed to quit \(appName)."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "quit-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}

