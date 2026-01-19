import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showOnboarding = false
    @State private var selectedTab = 0
    @Namespace private var animation
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                LibraryView(dataManager: dataManager)
                    .tag(0)
                
                StatsView(dataManager: dataManager)
                    .tag(1)
                
                GoalsView(dataManager: dataManager)
                    .tag(2)
                
                SettingsView(dataManager: dataManager)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            customTabBar
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(showOnboarding: $showOnboarding)
        }
        .onAppear {
            if !hasSeenOnboarding {
                showOnboarding = true
                hasSeenOnboarding = true
            }
        }
        .onChange(of: hasSeenOnboarding) { _, newValue in
            if !newValue {
                showOnboarding = true
                hasSeenOnboarding = true
            }
        }
    }
    
    private var customTabBar: some View {
        HStack(spacing: isRegularWidth ? 20 : 0) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab.rawValue,
                    animation: animation,
                    isRegularWidth: isRegularWidth
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab.rawValue
                    }
                    HapticManager.selection()
                }
            }
        }
        .padding(.horizontal, isRegularWidth ? 40 : 8)
        .padding(.vertical, isRegularWidth ? 14 : 12)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.adaptiveCardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 20, y: -5)
        )
        .frame(maxWidth: isRegularWidth ? 600 : nil)
        .padding(.horizontal, isRegularWidth ? 0 : 20)
        .padding(.bottom, isRegularWidth ? 20 : 10)
    }
}

enum TabItem: Int, CaseIterable {
    case library = 0
    case stats = 1
    case goals = 2
    case settings = 3
    
    var icon: String {
        switch self {
        case .library: return "books.vertical.fill"
        case .stats: return "chart.bar.fill"
        case .goals: return "target"
        case .settings: return "gearshape.fill"
        }
    }
    
    var title: String {
        switch self {
        case .library: return "Library"
        case .stats: return "Stats"
        case .goals: return "Goals"
        case .settings: return "Settings"
        }
    }
}

struct TabBarButton: View {
    let tab: TabItem
    let isSelected: Bool
    let animation: Namespace.ID
    var isRegularWidth: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(AppTheme.primaryGradient)
                            .frame(width: isRegularWidth ? 70 : 50, height: isRegularWidth ? 38 : 32)
                            .matchedGeometryEffect(id: "TAB_BG", in: animation)
                    }
                    
                    Image(systemName: tab.icon)
                        .font(.system(size: isRegularWidth ? 20 : 18, weight: .medium))
                        .foregroundColor(isSelected ? .white : Color.adaptiveSecondaryText)
                }
                .frame(height: isRegularWidth ? 38 : 32)
                
                Text(tab.title)
                    .font(.system(size: isRegularWidth ? 12 : 10, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? AppTheme.primary : Color.adaptiveSecondaryText)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
}
