import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("notificationHour") private var notificationHour = 21 // 9 PM default
    @AppStorage("notificationMinute") private var notificationMinute = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Notification Settings")
                .font(.custom("HelveticaNeue-Bold", size: 35))
                .foregroundColor(AppTheme.textPrimaryDark)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top)
            Form {
                Section {
                    Toggle("Enable Daily Reminder", isOn: $notificationsEnabled)
                        .font(.custom("HelveticaNeue", size: 18))
                        .foregroundColor(AppTheme.textPrimaryDark)
                        .tint(AppTheme.primaryBlue)
                        .onChange(of: notificationsEnabled) { oldValue, newValue in
                            if newValue {
                                requestNotificationPermission()
                                scheduleNotification()
                            } else {
                                cancelNotifications()
                            }
                        }
                }
                Section{
                    if notificationsEnabled {
                        DatePicker("Reminder Time",
                                   selection: Binding(
                                    get: {
                                        Calendar.current.date(from: DateComponents(hour: notificationHour, minute: notificationMinute)) ?? Date()
                                    },
                                    set: { date in
                                        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                                        notificationHour = components.hour ?? 21
                                        notificationMinute = components.minute ?? 0
                                        scheduleNotification()
                                    }
                                   ),
                                   displayedComponents: .hourAndMinute
                                   
                        )
                        .font(.custom("HelveticaNeue", size: 18))
                        .foregroundColor(AppTheme.textPrimaryDark)
                        .accentColor(AppTheme.primaryBlue)
                    }
                }
            }
            .scrollContentBackground(.hidden) 
            .background(Color(.systemBackground))
            .onAppear {
                checkNotificationStatus()
                // Request notification permission when view appears
                if notificationsEnabled {
                    requestNotificationPermission()
                }
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
            if !granted {
                // If permission denied, disable notifications
                DispatchQueue.main.async {
                    notificationsEnabled = false
                }
            }
        }
    }
    
    private func scheduleNotification() {
        // Check notification authorization status first
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings.authorizationStatus.rawValue)")
            guard settings.authorizationStatus == .authorized else {
                print("Notifications not authorized")
                return
            }
            
            // Cancel existing notifications before scheduling a new one
            self.cancelNotifications()
            
            let content = UNMutableNotificationContent()
            content.title = "Time to Journal"
            content.body = "Take a moment to reflect on your day"
            content.sound = UNNotificationSound.default
            content.badge = 1
            
            // For a DAILY repeating notification, only specify hour & minute
            var components = DateComponents()
            components.hour = self.notificationHour
            components.minute = self.notificationMinute
            // No need to set .year, .month, .day, or handle "if nextTriggerDate <= now"
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
            let request = UNNotificationRequest(identifier: "dailyJournal", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                } else {
                    print("Notification successfully scheduled")
                    // Verify pending notifications
                    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                        print("Number of pending notifications: \(requests.count)")
                        for request in requests {
                            if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                                print("Pending notification trigger date: \(trigger.nextTriggerDate() ?? Date())")
                            }
                        }
                    }
                }
            }
        }
    }

    
    private func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // Add this function to check notification status when needed
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                print("Authorization Status: \(settings.authorizationStatus.rawValue)")
                print("Alert Setting: \(settings.alertSetting.rawValue)")
                print("Sound Setting: \(settings.soundSetting.rawValue)")
                print("Badge Setting: \(settings.badgeSetting.rawValue)")
            }
        }
    }
}

struct NotificationSettings_Previews: PreviewProvider {
    static var previews: some View {
        // 3) Return the view for previews.
        return NotificationSettingsView()
    }
}

