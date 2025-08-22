//
//  NoteEchoApp.swift
//  NoteEcho
//
//  Created by Vera Ren on 2025-08-05.
//

import SwiftUI
import SwiftData

@main
struct NoteEchoApp: App {
    // Notification manager for daily highlight notifications
    @StateObject private var notificationManager = NotificationManager()
    @Environment(\.openWindow) private var openWindow
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Book.self,
            Highlight.self,
            NotificationSettings.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationManager)
                .onAppear {
                    Task {
                        await setupNotifications()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Settings...") {
                    openWindow(id: "settings")
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
        
        // Settings window
        Window("Settings", id: "settings") {
            SettingsView()
                .environmentObject(notificationManager)
        }
        .modelContainer(sharedModelContainer)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
    
    // MARK: - Notification Setup
    
    /// Sets up notifications when the app launches
    @MainActor
    private func setupNotifications() async {
        // Check current authorization status
        await notificationManager.checkAuthorizationStatus()
        
        // Request permission if not determined
        if notificationManager.authorizationStatus == .notDetermined {
            let granted = await notificationManager.requestNotificationPermission()
            print("Notification permission granted: \(granted)")
        }
        
        // Schedule notifications if authorized
        if notificationManager.isAuthorized {
            await scheduleNotificationsWithHighlights()
        }
    }
    
    /// Loads highlights from SwiftData and schedules notifications
    @MainActor
    private func scheduleNotificationsWithHighlights() async {
        // Create a context to fetch highlights
        let context = sharedModelContainer.mainContext
        let descriptor = FetchDescriptor<Highlight>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        
        do {
            let highlights = try context.fetch(descriptor)
            await notificationManager.scheduleDailyNotifications(with: highlights)
            print("Scheduled daily notifications with \(highlights.count) highlights")
        } catch {
            print("Error fetching highlights for notifications: \(error)")
        }
    }
}
