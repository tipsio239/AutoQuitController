//
//  AutoQuitControllerApp.swift
//  AutoQuitController
//
//  Main app entry point
//

import SwiftUI

@main
struct AutoQuitControllerApp: App {
    @StateObject private var appModel = AppModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appModel)
                .onAppear {
                    // Setup schedule service with the app model
                    ScheduleService.shared.setup(with: appModel)
                }
        }
        .windowStyle(.automatic)
        .defaultSize(width: 900, height: 700)
    }
}
