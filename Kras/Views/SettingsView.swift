import SwiftUI

struct SettingsView: View {
    @ObservedObject var dataManager: DataManager
    @StateObject private var notificationManager = NotificationManager.shared
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("reminderTime") private var reminderTime = Date()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var showPermissionDeniedAlert = false
    
    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.adaptiveBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("⚙️")
                                    .font(.title)
                                Text("Settings")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                    .foregroundColor(.adaptivePrimaryText)
                            }
                            Spacer()
                        }
                        
                        profileSummary
                        
                        if isRegularWidth {
                            HStack(alignment: .top, spacing: 20) {
                                appearanceSection
                                notificationsSection
                            }
                        } else {
                            appearanceSection
                            notificationsSection
                        }
                    }
                    .padding(.horizontal, isRegularWidth ? 40 : 16)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                    .frame(maxWidth: isRegularWidth ? 900 : .infinity)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationBarHidden(true)
            .alert("Notifications Disabled", isPresented: $showPermissionDeniedAlert) {
                Button("Open Settings") {
                    notificationManager.openSettings()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please enable notifications in Settings to receive reading reminders.")
            }
            .onAppear {
                Task {
                    await notificationManager.checkAuthorizationStatus()
                    if notificationsEnabled && !notificationManager.isAuthorized {
                        notificationsEnabled = false
                    }
                }
            }
            .onChange(of: reminderTime) { _, newTime in
                if notificationsEnabled && notificationManager.isAuthorized {
                    Task {
                        await notificationManager.scheduleDailyReminder(at: newTime)
                    }
                }
            }
        }
    }
    
    private var profileSummary: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryGradient)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 4) {
                Text("Reader")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.adaptivePrimaryText)
                
                Text("\(dataManager.finishedBooks.count) books completed")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.adaptiveSecondaryText)
            }
            
            HStack(spacing: isRegularWidth ? 60 : 30) {
                VStack(spacing: 4) {
                    Text("\(dataManager.currentStreak)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptivePrimaryText)
                    Text("day streak")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.adaptiveSecondaryText)
                }
                
                Rectangle()
                    .fill(Color.adaptiveDivider)
                    .frame(width: 1, height: 30)
                
                VStack(spacing: 4) {
                    Text(dataManager.totalPagesReadAllTime.abbreviated)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptivePrimaryText)
                    Text("pages read")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.adaptiveSecondaryText)
                }
                
                Rectangle()
                    .fill(Color.adaptiveDivider)
                    .frame(width: 1, height: 30)
                
                VStack(spacing: 4) {
                    Text("\(dataManager.books.count)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptivePrimaryText)
                    Text("total books")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.adaptiveSecondaryText)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: isRegularWidth ? 500 : .infinity)
        .background(Color.adaptiveCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge))
        .cardShadow()
    }
    
    private var appearanceSection: some View {
        SettingsSection(title: "Appearance", icon: "paintbrush.fill") {
            SettingsToggle(
                icon: "moon.fill",
                title: "Dark Mode",
                subtitle: "Switch between light and dark themes",
                isOn: $isDarkMode,
                color: .purple
            )
        }
        .frame(maxWidth: isRegularWidth ? .infinity : .infinity)
    }
    
    private var notificationsSection: some View {
        SettingsSection(title: "Notifications", icon: "bell.fill") {
            VStack(spacing: 0) {
                notificationToggle
                
                if notificationsEnabled && notificationManager.isAuthorized {
                    Divider()
                        .padding(.leading, 56)
                    
                    HStack {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                            .frame(width: 32)
                        
                        Text("Reminder Time")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.adaptivePrimaryText)
                        
                        Spacer()
                        
                        DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    .padding(14)
                }
                
                if notificationsEnabled && notificationManager.isAuthorized {
                    Divider()
                        .padding(.leading, 56)
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.green)
                            .frame(width: 32)
                        
                        Text("Reminder scheduled")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.adaptiveSecondaryText)
                        
                        Spacer()
                        
                        Text(reminderTime, style: .time)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.primary)
                    }
                    .padding(14)
                }
            }
        }
        .frame(maxWidth: isRegularWidth ? .infinity : .infinity)
    }
    
    private var notificationToggle: some View {
        HStack(spacing: 14) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 18))
                .foregroundColor(.orange)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Reading Reminders")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.adaptivePrimaryText)
                
                Text("Get reminded to read daily")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.adaptiveTertiaryText)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { notificationsEnabled && notificationManager.isAuthorized },
                set: { newValue in
                    handleNotificationToggle(newValue)
                }
            ))
            .labelsHidden()
            .tint(.orange)
        }
        .padding(14)
    }
    
    private func handleNotificationToggle(_ enabled: Bool) {
        if enabled {
            Task {
                let granted = await notificationManager.requestAuthorization()
                
                await MainActor.run {
                    if granted {
                        notificationsEnabled = true
                        HapticManager.notification(.success)
                        
                        Task {
                            await notificationManager.scheduleDailyReminder(at: reminderTime)
                        }
                    } else {
                        notificationsEnabled = false
                        
                        if notificationManager.authorizationStatus == .denied {
                            showPermissionDeniedAlert = true
                        }
                    }
                }
            }
        } else {
            notificationsEnabled = false
            Task {
                await notificationManager.removeAllReminders()
            }
            HapticManager.impact(.light)
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.adaptiveSecondaryText)
                
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.adaptiveSecondaryText)
                    .textCase(.uppercase)
            }
            .padding(.leading, 4)
            
            content
                .background(Color.adaptiveCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                .cardShadow()
        }
    }
}

struct SettingsToggle: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    var color: Color = AppTheme.primary
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.adaptivePrimaryText)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.adaptiveTertiaryText)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(color)
        }
        .padding(14)
    }
}
