import Foundation
import UserNotifications
import SwiftData

/// Manages daily highlight notifications for NoteEcho
@MainActor
class NotificationManager: ObservableObject {
    
    // MARK: - Constants
    private static let dailyNotificationIdentifier = "daily-echo-notification"
    private static let defaultNotificationHour = 9 // 9:00 AM
    private static let defaultNotificationMinute = 0
    
    // MARK: - Published Properties
    @Published var isAuthorized = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    // MARK: - Private Properties
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - Initialization
    init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Public Interface
    
    /// Requests notification permissions from the user
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            
            await updateAuthorizationStatus()
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }
    
    /// Schedules daily notifications with highlights (using default 9 AM time)
    func scheduleDailyNotifications(with highlights: [Highlight]) async {
        var dateComponents = DateComponents()
        dateComponents.hour = Self.defaultNotificationHour
        dateComponents.minute = Self.defaultNotificationMinute
        
        await scheduleDailyNotifications(with: highlights, at: dateComponents)
    }
    
    /// Schedules daily notifications with highlights at custom time
    func scheduleDailyNotifications(with highlights: [Highlight], at dateComponents: DateComponents) async {
        // Check if we have permission
        guard isAuthorized else {
            print("NotificationManager: No permission to schedule notifications")
            return
        }
        
        // Cancel existing notifications
        await cancelAllNotifications()
        
        // Don't schedule if no highlights available
        guard !highlights.isEmpty else {
            print("NotificationManager: No highlights available for notifications")
            return
        }
        
        // Schedule notification for daily delivery
        await scheduleNotification(with: highlights, at: dateComponents)
    }
    
    /// Cancels all scheduled notifications
    func cancelAllNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
        print("NotificationManager: Cancelled all pending notifications")
    }
    
    /// Checks current authorization status
    func checkAuthorizationStatus() async {
        await updateAuthorizationStatus()
    }
    
    // MARK: - Private Methods
    
    /// Updates the current authorization status
    private func updateAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        authorizationStatus = settings.authorizationStatus
        isAuthorized = settings.authorizationStatus == .authorized
        
        print("NotificationManager: Authorization status - \(authorizationStatus.rawValue)")
    }
    
    /// Schedules a daily repeating notification (default time)
    private func scheduleNotification(with highlights: [Highlight]) async {
        var dateComponents = DateComponents()
        dateComponents.hour = Self.defaultNotificationHour
        dateComponents.minute = Self.defaultNotificationMinute
        
        await scheduleNotification(with: highlights, at: dateComponents)
    }
    
    /// Schedules a daily repeating notification at custom time
    private func scheduleNotification(with highlights: [Highlight], at dateComponents: DateComponents) async {
        // Create notification content using daily highlight
        guard let dailyHighlight = highlights.dailyRandomHighlight else {
            print("NotificationManager: No daily highlight available")
            return
        }
        
        let content = createNotificationContent(for: dailyHighlight)
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        // Create the request
        let request = UNNotificationRequest(
            identifier: Self.dailyNotificationIdentifier,
            content: content,
            trigger: trigger
        )
        
        // Schedule the notification
        do {
            try await notificationCenter.add(request)
            let hour = dateComponents.hour ?? 0
            let minute = dateComponents.minute ?? 0
            print("NotificationManager: Successfully scheduled daily notification for \(hour):\(String(format: "%02d", minute))")
        } catch {
            print("NotificationManager: Error scheduling notification: \(error)")
        }
    }
    
    /// Creates notification content from a highlight
    private func createNotificationContent(for highlight: Highlight) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        
        // Set title with book information
        if let book = highlight.book {
            content.title = "Daily Echo: \(book.title)"
        } else {
            content.title = "Daily Echo"
        }
        
        // Set body with highlight content (truncate if too long)
        let maxBodyLength = 200
        let highlightText = highlight.content
        if highlightText.count > maxBodyLength {
            let truncated = String(highlightText.prefix(maxBodyLength)) + "..."
            content.body = truncated
        } else {
            content.body = highlightText
        }
        
        // Add subtitle with author if available
        if let book = highlight.book, !book.author.isEmpty {
            content.subtitle = "by \(book.author)"
        }
        
        // Set sound and badge
        content.sound = .default
        content.badge = 1
        
        // Add user info for handling notification taps
        content.userInfo = [
            "type": "daily-echo",
            "highlightId": highlight.id
        ]
        
        return content
    }
}

// MARK: - Authorization Status Extension
extension UNAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .denied:
            return "Denied"
        case .authorized:
            return "Authorized"
        case .provisional:
            return "Provisional"
        case .ephemeral:
            return "Ephemeral"
        @unknown default:
            return "Unknown"
        }
    }
}