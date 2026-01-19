import SwiftUI

struct StatCardView: View {
    let icon: String
    let title: String
    let value: String
    var subtitle: String? = nil
    var iconColor: Color = AppTheme.primary
    var gradient: LinearGradient? = nil
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.adaptivePrimaryText)
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.adaptiveSecondaryText)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.adaptiveTertiaryText)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            Group {
                if let gradient = gradient {
                    gradient.opacity(0.1)
                } else {
                    Color.adaptiveCardBackground
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(
                    gradient != nil ? Color.clear : Color.adaptiveDivider,
                    lineWidth: 1
                )
        )
        .cardShadow()
    }
}

struct FeaturedStatCard: View {
    let icon: String
    let title: String
    let value: String
    var subtitle: String? = nil
    var gradient: LinearGradient = AppTheme.primaryGradient
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.3))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(gradient)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge))
        .shadow(color: AppTheme.primary.opacity(0.3), radius: 20, y: 10)
    }
}

struct StreakCardView: View {
    let currentStreak: Int
    let longestStreak: Int
    let isActiveToday: Bool
    
    @State private var flameScale: CGFloat = 1
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.orange.opacity(0.3),
                                    Color.orange.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: isActiveToday ? "flame.fill" : "flame")
                        .font(.system(size: 36))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(flameScale)
                }
                
                VStack(spacing: 2) {
                    Text("\(currentStreak)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptivePrimaryText)
                    
                    Text("day streak")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.adaptiveSecondaryText)
                }
            }
            .frame(maxWidth: .infinity)
            
            Rectangle()
                .fill(Color.adaptiveDivider)
                .frame(width: 1, height: 80)
            
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.yellow)
                }
                
                VStack(spacing: 2) {
                    Text("\(longestStreak)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptivePrimaryText)
                    
                    Text("longest")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.adaptiveSecondaryText)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .background(Color.adaptiveCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge))
        .cardShadow()
        .onAppear {
            if isActiveToday {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    flameScale = 1.1
                }
            }
        }
    }
}

struct GoalProgressCard: View {
    let title: String
    let current: Int
    let target: Int
    var icon: String = "flag.fill"
    var gradient: LinearGradient = AppTheme.primaryGradient
    
    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(1, Double(current) / Double(target))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.primary)
                    
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.adaptivePrimaryText)
                }
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primary)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.adaptiveDivider)
                        .frame(height: 12)
                    
                    Capsule()
                        .fill(gradient)
                        .frame(width: geo.size.width * progress, height: 12)
                }
            }
            .frame(height: 12)
            
            HStack {
                Text("\(current) completed")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.adaptiveSecondaryText)
                
                Spacer()
                
                Text("\(target - current) to go")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.adaptiveTertiaryText)
            }
        }
        .padding(16)
        .background(Color.adaptiveCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .cardShadow()
    }
}

struct AchievementBadge: View {
    let icon: String
    let title: String
    let description: String
    var isUnlocked: Bool = false
    var gradient: LinearGradient = AppTheme.primaryGradient
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? gradient : LinearGradient(colors: [Color.gray.opacity(0.3)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 64, height: 64)
                
                if !isUnlocked {
                    Circle()
                        .fill(Color.adaptiveCardBackground)
                        .frame(width: 56, height: 56)
                }
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(isUnlocked ? .white : .adaptiveTertiaryText)
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isUnlocked ? .adaptivePrimaryText : .adaptiveTertiaryText)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.adaptiveTertiaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 100)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String? = nil
    var buttonAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppTheme.primary.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.primary.opacity(0.6))
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.adaptivePrimaryText)
                
                Text(message)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.adaptiveSecondaryText)
                    .multilineTextAlignment(.center)
            }
            
            if let buttonTitle = buttonTitle, let action = buttonAction {
                Button {
                    action()
                } label: {
                    Text(buttonTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(AppTheme.primaryGradient)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
        }
        .padding(40)
    }
}
