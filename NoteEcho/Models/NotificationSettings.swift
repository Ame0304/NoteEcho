import Foundation
import SwiftData

/// Settings model for notification preferences
@Model
final class NotificationSettings {
    
    // MARK: - Properties
    
    /// Whether daily notifications are enabled
    var isEnabled: Bool
    
    /// Hour for daily notifications (0-23)
    var notificationHour: Int
    
    /// Minute for daily notifications (0-59)
    var notificationMinute: Int
    
    /// When these settings were last updated
    var lastUpdated: Date
    
    // MARK: - Computed Properties
    
    /// Formatted time string for display (e.g., "9:00 AM")
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let calendar = Calendar.current
        let components = DateComponents(hour: notificationHour, minute: notificationMinute)
        if let date = calendar.date(from: components) {
            return formatter.string(from: date)
        }
        return "\(notificationHour):\(String(format: "%02d", notificationMinute))"
    }
    
    /// Date components for scheduling notifications
    var schedulingComponents: DateComponents {
        var components = DateComponents()
        components.hour = notificationHour
        components.minute = notificationMinute
        return components
    }
    
    // MARK: - Initialization
    
    init(
        isEnabled: Bool = true,
        notificationHour: Int = 9,
        notificationMinute: Int = 0
    ) {
        self.isEnabled = isEnabled
        self.notificationHour = notificationHour
        self.notificationMinute = notificationMinute
        self.lastUpdated = Date()
    }
    
    // MARK: - Methods
    
    /// Updates the notification time
    func updateTime(hour: Int, minute: Int) {
        guard hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59 else {
            print("NotificationSettings: Invalid time values - hour: \(hour), minute: \(minute)")
            return
        }
        
        notificationHour = hour
        notificationMinute = minute
        lastUpdated = Date()
    }
    
    /// Updates the notification time from a Date
    func updateTime(from date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        if let hour = components.hour, let minute = components.minute {
            updateTime(hour: hour, minute: minute)
        }
    }
    
    /// Toggles notification enabled state
    func toggleEnabled() {
        isEnabled.toggle()
        lastUpdated = Date()
    }
    
    /// Creates a Date object for today at the notification time
    func todaysNotificationDate() -> Date? {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: notificationHour, minute: notificationMinute, second: 0, of: Date())
    }
}

// MARK: - Default Settings

extension NotificationSettings {
    
    /// Creates default notification settings
    static func createDefault() -> NotificationSettings {
        return NotificationSettings(
            isEnabled: true,
            notificationHour: 9,
            notificationMinute: 0
        )
    }
    
    /// Validates if the current settings are reasonable
    func isValid() -> Bool {
        return notificationHour >= 0 && notificationHour <= 23 &&
               notificationMinute >= 0 && notificationMinute <= 59
    }
}