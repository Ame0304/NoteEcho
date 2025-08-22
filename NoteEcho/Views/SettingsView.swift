import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var notificationManager: NotificationManager
    
    // Query for notification settings
    @Query private var settingsQuery: [NotificationSettings]
    
    // Local state for the time picker
    @State private var selectedTime = Date()
    @State private var isUpdating = false
    
    // Computed property to get current settings or create default
    private var settings: NotificationSettings {
        if let existing = settingsQuery.first {
            return existing
        } else {
            // Create default settings if none exist
            let defaultSettings = NotificationSettings.createDefault()
            modelContext.insert(defaultSettings)
            try? modelContext.save()
            return defaultSettings
        }
    }
    
    private var theme: AppTheme {
        AppTheme(colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "bell.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(theme.themeColor)
                
                Text("Notification Settings")
                    .appFont(AppTypography.titleSemibold)
                    .foregroundColor(.primary)
                
                Text("Configure your daily highlight notifications")
                    .appFont(AppTypography.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            // Settings Form
            VStack(spacing: 20) {
                // Enable/Disable Toggle
                settingRow(
                    icon: "bell.fill",
                    title: "Daily Notifications",
                    subtitle: settings.isEnabled ? "Receive daily highlight reminders" : "Notifications are disabled"
                ) {
                    Toggle("", isOn: Binding(
                        get: { settings.isEnabled },
                        set: { _ in
                            settings.toggleEnabled()
                            saveSettings()
                        }
                    ))
                    .toggleStyle(SwitchToggleStyle(tint: theme.themeColor))
                }
                
                // Time Picker (only shown when enabled)
                if settings.isEnabled {
                    settingRow(
                        icon: "clock.fill",
                        title: "Notification Time",
                        subtitle: "Daily reminder at \(settings.formattedTime)"
                    ) {
                        DatePicker(
                            "",
                            selection: $selectedTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.compact)
                        .onChange(of: selectedTime) { _, newTime in
                            updateNotificationTime(newTime)
                        }
                    }
                }
                
                // Authorization Status Info
                authorizationStatusRow()
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Footer info
            VStack(spacing: 8) {
                Text("Notifications use highlights from your Apple Books library")
                    .appFont(AppTypography.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                if settings.isEnabled {
                    Text("Next notification: \(nextNotificationText())")
                        .appFont(AppTypography.caption)
                        .foregroundColor(theme.themeColor)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: 450, maxHeight: 500)
        .background(theme.cardBackgroundColor)
        .onAppear {
            setupInitialTime()
        }
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private func settingRow<Content: View>(
        icon: String,
        title: String,
        subtitle: String,
        @ViewBuilder control: () -> Content
    ) -> some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(theme.themeColor)
                .frame(width: 24, height: 24)
            
            // Text content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .appFont(AppTypography.bodyBold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .appFont(AppTypography.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Control
            control()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.gray.opacity(0.1) : Color.gray.opacity(0.05))
        )
    }
    
    @ViewBuilder
    private func authorizationStatusRow() -> some View {
        let status = notificationManager.authorizationStatus
        let (icon, title, subtitle, color) = authorizationInfo(for: status)
        
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .appFont(AppTypography.bodyBold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .appFont(AppTypography.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if status != .authorized {
                Button("Grant Permission") {
                    Task {
                        await notificationManager.requestNotificationPermission()
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.gray.opacity(0.1) : Color.gray.opacity(0.05))
        )
    }
    
    // MARK: - Helper Methods
    
    private func setupInitialTime() {
        let calendar = Calendar.current
        if let date = calendar.date(bySettingHour: settings.notificationHour, 
                                   minute: settings.notificationMinute, 
                                   second: 0, 
                                   of: Date()) {
            selectedTime = date
        }
    }
    
    private func updateNotificationTime(_ newTime: Date) {
        guard !isUpdating else { return }
        
        isUpdating = true
        settings.updateTime(from: newTime)
        saveSettings()
        
        // Reschedule notifications with new time
        Task {
            await rescheduleNotifications()
            isUpdating = false
        }
    }
    
    private func saveSettings() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving notification settings: \(error)")
        }
    }
    
    private func rescheduleNotifications() async {
        // Get current highlights and reschedule
        let descriptor = FetchDescriptor<Highlight>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        
        do {
            let highlights = try modelContext.fetch(descriptor)
            await notificationManager.scheduleDailyNotifications(with: highlights, at: settings.schedulingComponents)
        } catch {
            print("Error fetching highlights for rescheduling: \(error)")
        }
    }
    
    private func authorizationInfo(for status: UNAuthorizationStatus) -> (String, String, String, Color) {
        switch status {
        case .notDetermined:
            return ("questionmark.circle", "Permission Required", "Tap to allow notifications", .orange)
        case .denied:
            return ("xmark.circle", "Permission Denied", "Enable in System Preferences", .red)
        case .authorized:
            return ("checkmark.circle", "Permission Granted", "Notifications are enabled", .green)
        case .provisional:
            return ("clock.circle", "Provisional Access", "Limited notification access", .blue)
        case .ephemeral:
            return ("timer.circle", "Temporary Access", "Temporary notification access", .blue)
        @unknown default:
            return ("circle", "Unknown Status", "Check system settings", .gray)
        }
    }
    
    private func nextNotificationText() -> String {
        guard let nextDate = settings.todaysNotificationDate() else {
            return "Invalid time"
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        if nextDate > now {
            // Today's notification hasn't happened yet
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Today at \(formatter.string(from: nextDate))"
        } else {
            // Today's notification has passed, next is tomorrow
            return "Tomorrow at \(settings.formattedTime)"
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [NotificationSettings.self, Book.self, Highlight.self], inMemory: true)
        .environmentObject(NotificationManager())
}