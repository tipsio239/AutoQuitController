//
//  QuitManager.swift
//  AutoQuitController
//
//  Handles force quitting applications
//

import Foundation
import AppKit

class QuitManager {
    static let shared = QuitManager()
    
    private init() {}
    
    /// Force quits an application by bundle identifier
    /// - Parameters:
    ///   - bundleId: The bundle identifier of the app to quit
    ///   - appName: The display name of the app (for logging)
    /// - Returns: True if the app was successfully quit, false otherwise
    func forceQuitApp(bundleId: String, appName: String) -> Bool {
        let workspace = NSWorkspace.shared
        let runningApps = workspace.runningApplications
        
        guard let app = runningApps.first(where: { $0.bundleIdentifier == bundleId }) else {
            // App is not running
            return false
        }
        
        // Force terminate the app
        let success = app.forceTerminate()
        
        if success {
            print("Successfully force quit: \(appName) (\(bundleId))")
        } else {
            print("Failed to force quit: \(appName) (\(bundleId))")
        }
        
        return success
    }
    
    /// Attempts graceful quit first, then force quits if needed
    /// - Parameters:
    ///   - bundleId: The bundle identifier of the app to quit
    ///   - appName: The display name of the app (for logging)
    ///   - timeout: Timeout in seconds before force quitting (default: 2)
    /// - Returns: True if the app was successfully quit, false otherwise
    func quitApp(bundleId: String, appName: String, timeout: TimeInterval = 2.0) -> Bool {
        let workspace = NSWorkspace.shared
        let runningApps = workspace.runningApplications
        
        guard let app = runningApps.first(where: { $0.bundleIdentifier == bundleId }) else {
            // App is not running
            return false
        }
        
        // Try graceful termination first
        app.terminate()
        
        // Wait for graceful termination
        let startTime = Date()
        while app.isTerminated == false && Date().timeIntervalSince(startTime) < timeout {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        }
        
        // If still running, force terminate
        if !app.isTerminated {
            return forceQuitApp(bundleId: bundleId, appName: appName)
        }
        
        return true
    }
}

