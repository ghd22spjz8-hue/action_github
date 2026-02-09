import SwiftUI

struct GoalsView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showEditGoals = false
    @State private var selectedChallenge: ReadingChallenge?
    
    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.adaptiveBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("🎯")
                                    .font(.title)
                                Text("Goals")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                    .foregroundColor(.adaptivePrimaryText)
                            }
                            
                            Spacer()
                            
                            Button {
                                showEditGoals = true
                            } label: {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.adaptivePrimaryText)
                                    .padding(10)
                                    .background(Color.adaptiveCardBackground)
                                    .clipShape(Circle())
                            }
                        }
                        
                        mainGoalCard
                        
                        progressRings
                        
                        if isRegularWidth {
                            HStack(alignment: .top, spacing: 20) {
                                VStack(spacing: 24) {
                                    dailyGoalCard
                                    quoteCard
                                }
                                .frame(maxWidth: .infinity)
                                
                                challengesSection
                                    .frame(maxWidth: .infinity)
                            }
                        } else {
                            dailyGoalCard
                            challengesSection
                            quoteCard
                        }
                    }
                    .padding(.horizontal, isRegularWidth ? 40 : 16)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                    .frame(maxWidth: isRegularWidth ? 1000 : .infinity)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showEditGoals) {
                EditGoalsSheet(dataManager: dataManager)
            }
            .sheet(item: $selectedChallenge) { challenge in
                ChallengeDetailSheet(challenge: challenge, dataManager: dataManager)
            }
        }
    }
    
    private var mainGoalCard: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(Calendar.current.component(.year, from: Date())) Reading Challenge")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(dataManager.booksFinishedThisYear.count) of \(dataManager.readingGoal.targetBooks)")
                        .font(.system(size: isRegularWidth ? 42 : 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("books completed")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: isRegularWidth ? 12 : 10)
                        .frame(width: isRegularWidth ? 110 : 90, height: isRegularWidth ? 110 : 90)
                    
                    Circle()
                        .trim(from: 0, to: min(1, dataManager.goalProgress))
                        .stroke(Color.white, style: StrokeStyle(lineWidth: isRegularWidth ? 12 : 10, lineCap: .round))
                        .frame(width: isRegularWidth ? 110 : 90, height: isRegularWidth ? 110 : 90)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(dataManager.goalProgress * 100))%")
                        .font(.system(size: isRegularWidth ? 24 : 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            
            HStack(spacing: isRegularWidth ? 40 : 20) {
                VStack(spacing: 4) {
                    Text("\(max(0, dataManager.readingGoal.targetBooks - dataManager.booksFinishedThisYear.count))")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("books to go")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 1, height: 40)
                
                VStack(spacing: 4) {
                    Text("\(daysRemaining)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("days left")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 1, height: 40)
                
                VStack(spacing: 4) {
                    Text(booksPerMonth)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("books/month needed")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(24)
        .frame(maxWidth: isRegularWidth ? 700 : .infinity)
        .background(AppTheme.primaryGradient)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge))
        .shadow(color: AppTheme.primary.opacity(0.4), radius: 20, y: 10)
    }
    
    private var daysRemaining: Int {
        let calendar = Calendar.current
        let today = Date()
        let endOfYear = calendar.date(from: DateComponents(year: calendar.component(.year, from: today), month: 12, day: 31))!
        return calendar.dateComponents([.day], from: today, to: endOfYear).day ?? 0
    }
    
    private var booksPerMonth: String {
        let remaining = max(0, dataManager.readingGoal.targetBooks - dataManager.booksFinishedThisYear.count)
        let monthsLeft = max(1, 12 - Calendar.current.component(.month, from: Date()) + 1)
        let bpm = Double(remaining) / Double(monthsLeft)
        return bpm < 1 ? "<1" : String(format: "%.1f", bpm)
    }
    
    private var progressRings: some View {
        HStack(spacing: isRegularWidth ? 40 : 20) {
            LabeledProgressRing(
                title: "Books",
                value: "\(dataManager.booksFinishedThisYear.count)/\(dataManager.readingGoal.targetBooks)",
                progress: dataManager.goalProgress,
                size: isRegularWidth ? 120 : 100
            )
            
            LabeledProgressRing(
                title: "Pages",
                value: "\(dataManager.totalPagesReadThisYear.abbreviated)",
                progress: dataManager.pagesGoalProgress,
                size: isRegularWidth ? 120 : 100,
                gradient: AppTheme.coolGradient
            )
            
            LabeledProgressRing(
                title: "Today",
                value: "\(dataManager.pagesReadToday)/\(dataManager.dailyReadingGoal)",
                progress: min(1, Double(dataManager.pagesReadToday) / Double(dataManager.dailyReadingGoal)),
                size: isRegularWidth ? 120 : 100,
                gradient: AppTheme.warmGradient
            )
        }
        .padding(isRegularWidth ? 24 : 16)
        .frame(maxWidth: isRegularWidth ? 700 : .infinity)
        .background(Color.adaptiveCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .cardShadow()
    }
    
    private var dailyGoalCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Goal")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptivePrimaryText)
                    
                    Text("\(dataManager.dailyReadingGoal) pages per day")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.adaptiveSecondaryText)
                }
                
                Spacer()
                
                if dataManager.pagesReadToday >= dataManager.dailyReadingGoal {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Done!")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.success)
                } else {
                    Text("\(dataManager.dailyReadingGoal - dataManager.pagesReadToday) to go")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.orange)
                }
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.adaptiveDivider)
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            dataManager.pagesReadToday >= dataManager.dailyReadingGoal
                                ? AppTheme.successGradient
                                : AppTheme.warmGradient
                        )
                        .frame(
                            width: geo.size.width * min(1, Double(dataManager.pagesReadToday) / Double(dataManager.dailyReadingGoal)),
                            height: 12
                        )
                }
            }
            .frame(height: 12)
        }
        .padding(16)
        .background(Color.adaptiveCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .cardShadow()
    }
    
    private var challengesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Challenges")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.adaptivePrimaryText)
            
            if isRegularWidth {
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                    ForEach(ReadingChallenge.allChallenges) { challenge in
                        ChallengeCard(
                            challenge: challenge,
                            dataManager: dataManager
                        ) {
                            selectedChallenge = challenge
                        }
                    }
                }
            } else {
                ForEach(ReadingChallenge.allChallenges) { challenge in
                    ChallengeCard(
                        challenge: challenge,
                        dataManager: dataManager
                    ) {
                        selectedChallenge = challenge
                    }
                }
            }
        }
    }
    
    private var quoteCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "quote.opening")
                .font(.system(size: 24))
                .foregroundColor(AppTheme.primary.opacity(0.5))
            
            Text(motivationalQuote)
                .font(.system(size: 16, weight: .medium, design: .serif))
                .foregroundColor(.adaptivePrimaryText)
                .multilineTextAlignment(.center)
                .italic()
            
            Text("— \(quoteAuthor)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.adaptiveSecondaryText)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.adaptiveCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .cardShadow()
    }
    
    private var motivationalQuote: String {
        let quotes = [
            ("A reader lives a thousand lives before he dies.", "George R.R. Martin"),
            ("The more that you read, the more things you will know.", "Dr. Seuss"),
            ("Reading is to the mind what exercise is to the body.", "Joseph Addison"),
            ("Books are a uniquely portable magic.", "Stephen King"),
            ("Today a reader, tomorrow a leader.", "Margaret Fuller")
        ]
        let index = Calendar.current.component(.day, from: Date()) % quotes.count
        return quotes[index].0
    }
    
    private var quoteAuthor: String {
        let quotes = [
            ("A reader lives a thousand lives before he dies.", "George R.R. Martin"),
            ("The more that you read, the more things you will know.", "Dr. Seuss"),
            ("Reading is to the mind what exercise is to the body.", "Joseph Addison"),
            ("Books are a uniquely portable magic.", "Stephen King"),
            ("Today a reader, tomorrow a leader.", "Margaret Fuller")
        ]
        let index = Calendar.current.component(.day, from: Date()) % quotes.count
        return quotes[index].1
    }
}

struct ReadingChallenge: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let target: Int
    let type: ChallengeType
    let gradient: LinearGradient
    
    enum ChallengeType {
        case booksPerYear
        case pagesPerYear
        case streak
        case genres
    }
    
    @MainActor func progress(for dataManager: DataManager) -> Double {
        switch type {
        case .booksPerYear:
            return min(1, Double(dataManager.booksFinishedThisYear.count) / Double(target))
        case .pagesPerYear:
            return min(1, Double(dataManager.totalPagesReadThisYear) / Double(target))
        case .streak:
            return min(1, Double(dataManager.longestStreak) / Double(target))
        case .genres:
            return min(1, Double(dataManager.booksByGenre.count) / Double(target))
        }
    }
    
    @MainActor func currentValue(for dataManager: DataManager) -> Int {
        switch type {
        case .booksPerYear:
            return dataManager.booksFinishedThisYear.count
        case .pagesPerYear:
            return dataManager.totalPagesReadThisYear
        case .streak:
            return dataManager.longestStreak
        case .genres:
            return dataManager.booksByGenre.count
        }
    }
    
    static let allChallenges: [ReadingChallenge] = [
        ReadingChallenge(
            title: "Book Marathon",
            description: "Read 52 books this year",
            icon: "books.vertical.fill",
            target: 52,
            type: .booksPerYear,
            gradient: AppTheme.primaryGradient
        ),
        ReadingChallenge(
            title: "Page Turner",
            description: "Read 10,000 pages this year",
            icon: "doc.text.fill",
            target: 10000,
            type: .pagesPerYear,
            gradient: AppTheme.coolGradient
        ),
        ReadingChallenge(
            title: "Consistency King",
            description: "Reach a 30-day reading streak",
            icon: "flame.fill",
            target: 30,
            type: .streak,
            gradient: AppTheme.warmGradient
        ),
        ReadingChallenge(
            title: "Genre Explorer",
            description: "Read from 8 different genres",
            icon: "sparkles",
            target: 8,
            type: .genres,
            gradient: AppTheme.sunsetGradient
        )
    ]
}

struct ChallengeCard: View {
    let challenge: ReadingChallenge
    @ObservedObject var dataManager: DataManager
    let onTap: () -> Void
    
    private var progress: Double {
        challenge.progress(for: dataManager)
    }
    
    private var isCompleted: Bool {
        progress >= 1
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isCompleted ? challenge.gradient : LinearGradient(colors: [Color.adaptiveDivider], startPoint: .top, endPoint: .bottom))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: isCompleted ? "checkmark" : challenge.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isCompleted ? .white : .adaptiveSecondaryText)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.adaptivePrimaryText)
                    
                    Text(challenge.description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.adaptiveSecondaryText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(isCompleted ? AppTheme.success : .adaptivePrimaryText)
                    
                    MiniProgressRing(
                        progress: progress,
                        size: 28,
                        lineWidth: 3,
                        color: isCompleted ? AppTheme.success : AppTheme.primary
                    )
                }
            }
            .padding(14)
            .background(Color.adaptiveCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isCompleted ? AppTheme.success.opacity(0.3) : Color.clear, lineWidth: 2)
            )
            .cardShadow()
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct EditGoalsSheet: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var yearlyBooks: Double
    @State private var yearlyPages: Double
    @State private var dailyPages: Double
    
    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
        self._yearlyBooks = State(initialValue: Double(dataManager.readingGoal.targetBooks))
        self._yearlyPages = State(initialValue: Double(dataManager.readingGoal.targetPages))
        self._dailyPages = State(initialValue: Double(dataManager.dailyReadingGoal))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.adaptiveBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        GoalSlider(
                            title: "Yearly Book Goal",
                            value: $yearlyBooks,
                            range: 1...100,
                            step: 1,
                            unit: "books",
                            icon: "books.vertical.fill",
                            color: AppTheme.primary
                        )
                        
                        GoalSlider(
                            title: "Yearly Pages Goal",
                            value: $yearlyPages,
                            range: 1000...50000,
                            step: 500,
                            unit: "pages",
                            icon: "doc.text.fill",
                            color: .cyan
                        )
                        
                        GoalSlider(
                            title: "Daily Pages Goal",
                            value: $dailyPages,
                            range: 5...200,
                            step: 5,
                            unit: "pages",
                            icon: "calendar",
                            color: .orange
                        )
                        
                        Text("Setting achievable goals helps build consistent reading habits. Start small and increase over time!")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.adaptiveSecondaryText)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .padding()
                    .frame(maxWidth: isRegularWidth ? 600 : .infinity)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Edit Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveGoals()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.primary)
                }
            }
        }
    }
    
    private func saveGoals() {
        dataManager.updateReadingGoal(books: Int(yearlyBooks), pages: Int(yearlyPages))
        dataManager.updateDailyGoal(Int(dailyPages))
        HapticManager.notification(.success)
        dismiss()
    }
}

struct GoalSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.adaptivePrimaryText)
                
                Spacer()
                
                Text("\(Int(value)) \(unit)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }
            
            Slider(value: $value, in: range, step: step)
                .tint(color)
        }
        .padding(16)
        .background(Color.adaptiveCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct ChallengeDetailSheet: View {
    let challenge: ReadingChallenge
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(challenge.gradient.opacity(0.2))
                        .frame(width: isRegularWidth ? 150 : 120, height: isRegularWidth ? 150 : 120)
                    
                    Image(systemName: challenge.icon)
                        .font(.system(size: isRegularWidth ? 60 : 50))
                        .foregroundStyle(challenge.gradient)
                }
                
                VStack(spacing: 8) {
                    Text(challenge.title)
                        .font(.system(size: isRegularWidth ? 32 : 26, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptivePrimaryText)
                    
                    Text(challenge.description)
                        .font(.system(size: isRegularWidth ? 18 : 16, weight: .medium))
                        .foregroundColor(.adaptiveSecondaryText)
                }
                
                VStack(spacing: 16) {
                    ProgressRingView(
                        progress: challenge.progress(for: dataManager),
                        size: isRegularWidth ? 180 : 140,
                        lineWidth: isRegularWidth ? 18 : 14,
                        foregroundGradient: challenge.gradient
                    )
                    
                    Text("\(challenge.currentValue(for: dataManager)) / \(challenge.target)")
                        .font(.system(size: isRegularWidth ? 24 : 20, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptivePrimaryText)
                }
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Text("Close")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: isRegularWidth ? 400 : .infinity)
                        .padding(.vertical, 16)
                        .background(challenge.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, isRegularWidth ? 100 : 16)
            }
            .padding()
            .background(Color.adaptiveBackground.ignoresSafeArea())
        }
    }
}
