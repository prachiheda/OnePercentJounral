import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("notificationHour") private var notificationHour = 21 // 9 PM default
    @AppStorage("notificationMinute") private var notificationMinute = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Notification Settings")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top)
            Form {
                Section {
                    Toggle("Enable Daily Reminder", isOn: $notificationsEnabled)
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
                    }
                }
            }
            .scrollContentBackground(.hidden) 
            .background(Color(.systemBackground))
            .onAppear {
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
        // Cancel existing notifications before scheduling new one
        cancelNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Journal"
        content.body = "Take a moment to reflect on your day"
        content.sound = .default
        
        // Create date components for the notification
        var dateComponents = DateComponents()
        dateComponents.hour = notificationHour
        dateComponents.minute = notificationMinute
        
        // Create the trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create the request
        let request = UNNotificationRequest(identifier: "dailyJournal", content: content, trigger: trigger)
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    private func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
