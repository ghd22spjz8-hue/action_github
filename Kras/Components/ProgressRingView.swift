import SwiftUI

struct ProgressRingView: View {
    let progress: Double
    var size: CGFloat = 100
    var lineWidth: CGFloat = 10
    var backgroundColor: Color = Color.adaptiveDivider
    var foregroundGradient: LinearGradient = AppTheme.primaryGradient
    var showPercentage: Bool = true
    var animated: Bool = true
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: animated ? animatedProgress : progress)
                .stroke(
                    foregroundGradient,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
            
            if showPercentage {
                Text("\(Int((animated ? animatedProgress : progress) * 100))%")
                    .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
                    .foregroundColor(.adaptivePrimaryText)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            if animated {
                withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.2)) {
                    animatedProgress = progress
                }
            }
        }
        .onChange(of: progress) { _, newValue in
            if animated {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animatedProgress = newValue
                }
            }
        }
    }
}

struct LabeledProgressRing: View {
    let title: String
    let value: String
    let progress: Double
    var size: CGFloat = 120
    var gradient: LinearGradient = AppTheme.primaryGradient
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.adaptiveDivider, lineWidth: 12)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(gradient, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Text(value)
                        .font(.system(size: size * 0.24, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptivePrimaryText)
                }
            }
            .frame(width: size, height: size)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.adaptiveSecondaryText)
        }
    }
}

struct MiniProgressRing: View {
    let progress: Double
    var size: CGFloat = 24
    var lineWidth: CGFloat = 3
    var color: Color = AppTheme.primary
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
    }
}

struct CompletionCheckmark: View {
    var isComplete: Bool
    var size: CGFloat = 60
    
    @State private var checkmarkProgress: CGFloat = 0
    @State private var circleProgress: CGFloat = 0
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: circleProgress)
                .stroke(AppTheme.successGradient, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            CheckmarkShape()
                .trim(from: 0, to: checkmarkProgress)
                .stroke(AppTheme.success, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .padding(size * 0.25)
        }
        .frame(width: size, height: size)
        .onChange(of: isComplete) { _, newValue in
            if newValue {
                withAnimation(.easeOut(duration: 0.3)) {
                    circleProgress = 1
                }
                withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
                    checkmarkProgress = 1
                }
            } else {
                circleProgress = 0
                checkmarkProgress = 0
            }
        }
        .onAppear {
            if isComplete {
                circleProgress = 1
                checkmarkProgress = 1
            }
        }
    }
}

struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width * 0.15, y: height * 0.5))
        path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.75))
        path.addLine(to: CGPoint(x: width * 0.85, y: height * 0.25))
        
        return path
    }
}

struct WeeklyProgressView: View {
    let dailyPages: [Int]
    let goal: Int
    
    private let weekdays = ["M", "T", "W", "T", "F", "S", "S"]
    
    private var maxValue: Int {
        max(dailyPages.max() ?? 0, goal)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<7, id: \.self) { index in
                    VStack(spacing: 6) {
                        GeometryReader { geo in
                            let height = maxValue > 0
                                ? CGFloat(dailyPages[index]) / CGFloat(maxValue) * geo.size.height
                                : 0
                            
                            VStack {
                                Spacer()
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        dailyPages[index] >= goal
                                            ? AnyShapeStyle(AppTheme.successGradient)
                                            : AnyShapeStyle(AppTheme.primaryGradient.opacity(0.7))
                                    )
                                    .frame(height: max(4, height))
                            }
                        }
                        
                        Text(weekdays[index])
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.adaptiveSecondaryText)
                    }
                }
            }
            .frame(height: 80)
            
            HStack(spacing: 4) {
                Rectangle()
                    .fill(AppTheme.success)
                    .frame(width: 12, height: 2)
                Text("Daily goal: \(goal) pages")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.adaptiveTertiaryText)
            }
        }
        .padding(16)
        .background(Color.adaptiveCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }
}
