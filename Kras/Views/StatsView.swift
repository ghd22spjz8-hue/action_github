import SwiftUI

struct StatsView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedTimeRange: TimeRange = .thisYear
    @State private var animateStats = false
    
    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }
    
    enum TimeRange: String, CaseIterable {
        case thisWeek = "Week"
        case thisMonth = "Month"
        case thisYear = "Year"
        case allTime = "All Time"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.adaptiveBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("📊")
                                    .font(.title)
                                Text("Statistics")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                    .foregroundColor(.adaptivePrimaryText)
                            }
                            Spacer()
                        }
                        
                        if isRegularWidth {
                            HStack(alignment: .top, spacing: 20) {
                                VStack(spacing: 24) {
                                    headerStats
                                    StreakCardView(
                                        currentStreak: dataManager.currentStreak,
                                        longestStreak: dataManager.longestStreak,
                                        isActiveToday: dataManager.pagesReadToday > 0
                                    )
                                }
                                .frame(maxWidth: .infinity)
                                
                                VStack(spacing: 24) {
                                    timeRangePicker
                                    goalsSection
                                }
                                .frame(maxWidth: .infinity)
                            }
                        } else {
                            headerStats
                            StreakCardView(
                                currentStreak: dataManager.currentStreak,
                                longestStreak: dataManager.longestStreak,
                                isActiveToday: dataManager.pagesReadToday > 0
                            )
                            timeRangePicker
                            goalsSection
                        }
                        
                        statsGrid
                        
                        if isRegularWidth {
                            HStack(alignment: .top, spacing: 20) {
                                monthlyChart
                                    .frame(maxWidth: .infinity)
                                genreBreakdown
                                    .frame(maxWidth: .infinity)
                            }
                        } else {
                            monthlyChart
                            genreBreakdown
                        }
                        
                        achievementsSection
                    }
                    .padding(.horizontal, isRegularWidth ? 40 : 16)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                    .frame(maxWidth: isRegularWidth ? 1200 : .infinity)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                    animateStats = true
                }
            }
        }
    }
    
    private var headerStats: some View {
        FeaturedStatCard(
            icon: "book.fill",
            title: "Books Read This Year",
            value: "\(dataManager.booksFinishedThisYear.count)",
            subtitle: "Goal: \(dataManager.readingGoal.targetBooks) books",
            gradient: AppTheme.primaryGradient
        )
    }
    
    private var timeRangePicker: some View {
        HStack(spacing: 8) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Button {
                    withAnimation(.smoothSpring) {
                        selectedTimeRange = range
                    }
                    HapticManager.selection()
                } label: {
                    Text(range.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedTimeRange == range ? .white : .adaptiveSecondaryText)
                        .padding(.horizontal, isRegularWidth ? 20 : 16)
                        .padding(.vertical, 10)
                        .background(
                            selectedTimeRange == range
                                ? AppTheme.primaryGradient
                                : LinearGradient(colors: [Color.adaptiveCardBackground], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(
                                    selectedTimeRange == range ? Color.clear : Color.adaptiveDivider,
                                    lineWidth: 1
                                )
                        )
                }
            }
        }
    }
    
    private var goalsSection: some View {
        VStack(spacing: 14) {
            GoalProgressCard(
                title: "Yearly Book Goal",
                current: dataManager.booksFinishedThisYear.count,
                target: dataManager.readingGoal.targetBooks,
                icon: "books.vertical.fill"
            )
            
            GoalProgressCard(
                title: "Yearly Pages Goal",
                current: dataManager.totalPagesReadThisYear,
                target: dataManager.readingGoal.targetPages,
                icon: "doc.text.fill",
                gradient: AppTheme.coolGradient
            )
        }
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: isRegularWidth ? 3 : 2), spacing: 14) {
            StatCardView(
                icon: "doc.text.fill",
                title: "Pages Today",
                value: "\(dataManager.pagesReadToday)",
                subtitle: "Goal: \(dataManager.dailyReadingGoal)",
                iconColor: AppTheme.primary
            )
            
            StatCardView(
                icon: "calendar",
                title: "This Week",
                value: "\(dataManager.pagesReadThisWeek)",
                subtitle: "pages read",
                iconColor: .orange
            )
            
            StatCardView(
                icon: "chart.line.uptrend.xyaxis",
                title: "Daily Average",
                value: dataManager.averagePagesPerDay.oneDecimal,
                subtitle: "pages/day",
                iconColor: .green
            )
            
            StatCardView(
                icon: "book.closed.fill",
                title: "Total Books",
                value: "\(dataManager.finishedBooks.count)",
                subtitle: "finished",
                iconColor: .purple
            )
            
            StatCardView(
                icon: "text.document.fill",
                title: "All-Time Pages",
                value: dataManager.totalPagesReadAllTime.abbreviated,
                subtitle: "read",
                iconColor: .blue
            )
            
            StatCardView(
                icon: "book.fill",
                title: "Currently Reading",
                value: "\(dataManager.currentlyReading.count)",
                subtitle: "books",
                iconColor: .cyan
            )
        }
    }
    
    private var monthlyChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reading Trend")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.adaptivePrimaryText)
            
            let stats = dataManager.monthlyStats(for: 6)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(stats.indices, id: \.self) { index in
                    let stat = stats[index]
                    let maxPages = stats.map { $0.pages }.max() ?? 1
                    let height = maxPages > 0 ? CGFloat(stat.pages) / CGFloat(maxPages) : 0
                    
                    VStack(spacing: 8) {
                        Text("\(stat.pages)")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundColor(.adaptiveSecondaryText)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                index == stats.count - 1
                                    ? AppTheme.primaryGradient
                                    : LinearGradient(colors: [AppTheme.primary.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(height: max(8, (isRegularWidth ? 150 : 100) * height))
                        
                        Text(stat.month)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.adaptiveSecondaryText)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: isRegularWidth ? 190 : 140)
        }
        .padding(16)
        .background(Color.adaptiveCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .cardShadow()
    }
    
    private var genreBreakdown: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Genre Breakdown")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.adaptivePrimaryText)
            
            let genreStats = dataManager.booksByGenre
                .map { (genre: $0.key, count: $0.value.count) }
                .sorted { $0.count > $1.count }
                .prefix(5)
            
            if genreStats.isEmpty {
                Text("No books yet")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.adaptiveTertiaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(genreStats), id: \.genre) { stat in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(stat.genre.color.opacity(0.15))
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: stat.genre.icon)
                                    .font(.system(size: 14))
                                    .foregroundColor(stat.genre.color)
                            }
                            
                            Text(stat.genre.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.adaptivePrimaryText)
                            
                            Spacer()
                            
                            Text("\(stat.count)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.adaptivePrimaryText)
                            
                            let maxCount = genreStats.map { $0.count }.max() ?? 1
                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(stat.genre.color)
                                    .frame(width: geo.size.width * (CGFloat(stat.count) / CGFloat(maxCount)))
                            }
                            .frame(width: isRegularWidth ? 100 : 60, height: 8)
                        }
                    }
                }
            }
        }
        .padding(16)
        .frame(minHeight: isRegularWidth ? 230 : 0)
        .background(Color.adaptiveCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .cardShadow()
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Achievements")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.adaptivePrimaryText)
                
                Spacer()
                
                Text("\(unlockedAchievements)/\(totalAchievements)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.adaptiveSecondaryText)
            }
            
            if isRegularWidth {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 5), spacing: 16) {
                    achievementBadges
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        achievementBadges
                    }
                }
                .scrollClipDisabled()
            }
        }
        .padding(16)
        .background(Color.adaptiveCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .cardShadow()
    }
    
    @ViewBuilder
    private var achievementBadges: some View {
        AchievementBadge(
            icon: "flame.fill",
            title: "On Fire",
            description: "7-day streak",
            isUnlocked: dataManager.currentStreak >= 7,
            gradient: AppTheme.warmGradient
        )
        
        AchievementBadge(
            icon: "book.fill",
            title: "First Book",
            description: "Finish 1 book",
            isUnlocked: dataManager.finishedBooks.count >= 1,
            gradient: AppTheme.primaryGradient
        )
        
        AchievementBadge(
            icon: "books.vertical.fill",
            title: "Bookworm",
            description: "Finish 10 books",
            isUnlocked: dataManager.finishedBooks.count >= 10,
            gradient: AppTheme.coolGradient
        )
        
        AchievementBadge(
            icon: "star.fill",
            title: "Dedicated",
            description: "30-day streak",
            isUnlocked: dataManager.longestStreak >= 30,
            gradient: AppTheme.sunsetGradient
        )
        
        AchievementBadge(
            icon: "trophy.fill",
            title: "Champion",
            description: "Reach yearly goal",
            isUnlocked: dataManager.booksFinishedThisYear.count >= dataManager.readingGoal.targetBooks,
            gradient: LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
        )
    }
    
    private var unlockedAchievements: Int {
        var count = 0
        if dataManager.currentStreak >= 7 { count += 1 }
        if dataManager.finishedBooks.count >= 1 { count += 1 }
        if dataManager.finishedBooks.count >= 10 { count += 1 }
        if dataManager.longestStreak >= 30 { count += 1 }
        if dataManager.booksFinishedThisYear.count >= dataManager.readingGoal.targetBooks { count += 1 }
        return count
    }
    
    private var totalAchievements: Int { 5 }
}
