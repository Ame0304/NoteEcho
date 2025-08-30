import SwiftUI
import SwiftData
import UserNotifications

enum SaveButtonState {
    case hidden
    case normal
    case saving
    case success
}

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var notificationManager: NotificationManager
    
    // Query for notification settings
    @Query private var settingsQuery: [NotificationSettings]
    
    // Local state for the time picker
    @State private var selectedTime = Date()
    @State private var isUpdating = false
    @State private var saveButtonState: SaveButtonState = .hidden
    
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
                // Enable/Disable Toggle with Permission Handling
                settingRow(
                    icon: "bell.fill",
                    title: "Daily Notifications",
                    subtitle: notificationSubtitle()
                ) {
                    HStack(spacing: 12) {
                        if notificationManager.authorizationStatus != .authorized {
                            Button("Grant Permission") {
                                Task {
                                    await notificationManager.requestNotificationPermission()
                                }
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        } else {
                            Toggle("", isOn: Binding(
                                get: { settings.isEnabled },
                                set: { _ in
                                    settings.toggleEnabled()
                                    saveSettings()
                                }
                            ))
                            .toggleStyle(SwitchToggleStyle(tint: theme.themeColor))
                        }
                    }
                }
                
                // Time Picker (only shown when enabled and authorized)
                if settings.isEnabled && notificationManager.authorizationStatus == .authorized {
                    settingRow(
                        icon: "clock.fill",
                        title: "Notification Time",
                        subtitle: timePickerSubtitle()
                    ) {
                        HStack(spacing: 12) {
                            DatePicker(
                                "",
                                selection: $selectedTime,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.compact)
                            .onChange(of: selectedTime) { _, _ in
                                updateSaveButtonState()
                            }
                            
                        }
                    }
                }
                
            }
            .padding(.horizontal, 20)
            
            // Save Button (only shown when there are unsaved changes)
            if saveButtonState != .hidden {
                saveButton()
                    .padding(.horizontal, 20)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
            
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
        .onChange(of: settings.notificationHour) { _, _ in
            setupInitialTime()
        }
        .onChange(of: settings.notificationMinute) { _, _ in
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
        
        // Show success feedback
        withAnimation(.easeInOut(duration: 0.3)) {
            saveButtonState = .success
        }
        
        // Reschedule notifications with new time
        Task {
            await rescheduleNotifications()
            isUpdating = false
            
            // Hide save button after delay
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            withAnimation(.easeOut(duration: 0.2)) {
                saveButtonState = .hidden
            }
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
    
    
    private func nextNotificationText() -> String {
        guard let nextDate = settings.todaysNotificationDate() else {
            return "Invalid time"
        }
        
        let now = Date()
        
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
    
    private func notificationSubtitle() -> String {
        let status = notificationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            return "Tap 'Grant Permission' to enable notifications"
        case .denied:
            return "Permission denied - Enable in System Preferences"
        case .authorized:
            return settings.isEnabled ? "Receive daily highlight reminders" : "Notifications are disabled"
        case .provisional:
            return "Limited notification access"
        case .ephemeral:
            return "Temporary notification access"
        @unknown default:
            return "Check notification settings"
        }
    }
    
    private func timePickerSubtitle() -> String {
        if saveButtonState == .success {
            return "Updated to \(settings.formattedTime)"
        } else if hasUnsavedChanges {
            return "Daily reminder at \(settings.formattedTime) (unsaved changes)"
        } else {
            return "Daily reminder at \(settings.formattedTime)"
        }
    }
    
    private var hasUnsavedChanges: Bool {
        guard let currentNotificationTime = settings.todaysNotificationDate() else { return false }
        let calendar = Calendar.current
        let selectedComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
        let currentComponents = calendar.dateComponents([.hour, .minute], from: currentNotificationTime)
        
        return selectedComponents.hour != currentComponents.hour || selectedComponents.minute != currentComponents.minute
    }
    
    private func updateSaveButtonState() {
        withAnimation(.easeInOut(duration: 0.2)) {
            if hasUnsavedChanges && saveButtonState != .saving && saveButtonState != .success {
                saveButtonState = .normal
            } else if !hasUnsavedChanges && saveButtonState == .normal {
                saveButtonState = .hidden
            }
        }
    }
    
    @ViewBuilder
    private func saveButton() -> some View {
        Button(action: {
            saveButtonState = .saving
            updateNotificationTime(selectedTime)
        }) {
            HStack(spacing: 8) {
                switch saveButtonState {
                case .normal:
                    Image(systemName: "checkmark.circle")
                    Text("Save Changes")
                case .saving:
                    ProgressView()
                        .controlSize(.small)
                    Text("Saving...")
                case .success:
                    Image(systemName: "checkmark.circle.fill")
                    Text("Saved!")
                case .hidden:
                    EmptyView()
                }
            }
            .appFont(AppTypography.bodyBold)
            .foregroundColor(.white)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(theme.themeColor)
        .disabled(saveButtonState == .saving || saveButtonState == .success)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [NotificationSettings.self, Book.self, Highlight.self], inMemory: true)
        .environmentObject(NotificationManager())
}
