import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var currentPage = 0
    @State private var animateContent = false
    
    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "books.vertical.fill",
            title: "Track Your Reading",
            description: "Add books to your library and track your progress as you read. Never forget where you left off.",
            gradient: AppTheme.primaryGradient,
            backgroundColor: Color(hex: "6366F1")
        ),
        OnboardingPage(
            icon: "chart.bar.fill",
            title: "View Statistics",
            description: "See detailed statistics about your reading habits. Track pages read, time spent, and more.",
            gradient: AppTheme.coolGradient,
            backgroundColor: Color(hex: "06B6D4")
        ),
        OnboardingPage(
            icon: "target",
            title: "Set Goals",
            description: "Challenge yourself with yearly reading goals. Read 52 books this year and become a reading champion!",
            gradient: AppTheme.warmGradient,
            backgroundColor: Color(hex: "F59E0B")
        ),
        OnboardingPage(
            icon: "flame.fill",
            title: "Build Streaks",
            description: "Read every day to build your streak. Stay consistent and develop a lifelong reading habit.",
            gradient: AppTheme.sunsetGradient,
            backgroundColor: Color(hex: "F43F5E")
        )
    ]
    
    var body: some View {
        ZStack {
            pages[currentPage].backgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: currentPage)
            
            GeometryReader { geo in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: isRegularWidth ? 500 : 300, height: isRegularWidth ? 500 : 300)
                    .offset(x: -100, y: -50)
                
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: isRegularWidth ? 400 : 200, height: isRegularWidth ? 400 : 200)
                    .offset(x: geo.size.width - 50, y: geo.size.height - 200)
            }
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button {
                            completeOnboarding()
                        } label: {
                            Text("Skip")
                                .font(.system(size: isRegularWidth ? 18 : 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.horizontal, isRegularWidth ? 40 : 16)
                .padding(.top, 10)
                
                Spacer()
                
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        pageView(pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.smoothSpring, value: currentPage)
                
                HStack(spacing: 10) {
                    ForEach(pages.indices, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.4))
                            .frame(width: currentPage == index ? (isRegularWidth ? 32 : 24) : (isRegularWidth ? 10 : 8), height: isRegularWidth ? 10 : 8)
                            .animation(.smoothSpring, value: currentPage)
                    }
                }
                .padding(.bottom, isRegularWidth ? 40 : 30)
                
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation(.smoothSpring) {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                    HapticManager.impact(.light)
                } label: {
                    HStack(spacing: 8) {
                        Text(currentPage < pages.count - 1 ? "Continue" : "Get Started")
                            .font(.system(size: isRegularWidth ? 20 : 18, weight: .bold))
                        
                        Image(systemName: currentPage < pages.count - 1 ? "arrow.right" : "checkmark")
                            .font(.system(size: isRegularWidth ? 18 : 16, weight: .bold))
                    }
                    .foregroundColor(pages[currentPage].backgroundColor)
                    .frame(maxWidth: isRegularWidth ? 400 : .infinity)
                    .padding(.vertical, isRegularWidth ? 20 : 18)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, isRegularWidth ? 100 : 24)
                .padding(.bottom, isRegularWidth ? 60 : 40)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateContent = true
            }
        }
    }
    
    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: isRegularWidth ? 40 : 30) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: isRegularWidth ? 200 : 140, height: isRegularWidth ? 200 : 140)
                
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: isRegularWidth ? 260 : 180, height: isRegularWidth ? 260 : 180)
                
                Image(systemName: page.icon)
                    .font(.system(size: isRegularWidth ? 80 : 60))
                    .foregroundColor(.white)
            }
            .scaleEffect(animateContent ? 1 : 0.8)
            .opacity(animateContent ? 1 : 0)
            
            VStack(spacing: isRegularWidth ? 20 : 16) {
                Text(page.title)
                    .font(.system(size: isRegularWidth ? 42 : 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(page.description)
                    .font(.system(size: isRegularWidth ? 20 : 17, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, isRegularWidth ? 60 : 20)
                    .frame(maxWidth: isRegularWidth ? 600 : .infinity)
            }
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 30)
        }
        .padding(.horizontal)
    }
    
    private func completeOnboarding() {
        HapticManager.notification(.success)
        withAnimation(.easeInOut(duration: 0.3)) {
            showOnboarding = false
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let gradient: LinearGradient
    let backgroundColor: Color
}
