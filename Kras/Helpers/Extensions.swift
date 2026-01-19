import SwiftUI

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    var isThisMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
    
    var isThisYear: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var startOfWeek: Date {
        let components = Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return Calendar.current.date(from: components) ?? self
    }
    
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
    }
    
    var startOfYear: Date {
        let components = Calendar.current.dateComponents([.year], from: self)
        return Calendar.current.date(from: components) ?? self
    }
    
    var year: Int {
        Calendar.current.component(.year, from: self)
    }
    
    var month: Int {
        Calendar.current.component(.month, from: self)
    }
    
    var day: Int {
        Calendar.current.component(.day, from: self)
    }
    
    var weekday: Int {
        Calendar.current.component(.weekday, from: self)
    }
    
    func formatted(as format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    var relativeFormatted: String {
        if isToday {
            return "Today"
        } else if isYesterday {
            return "Yesterday"
        } else if isThisWeek {
            return formatted(as: "EEEE")
        } else if isThisYear {
            return formatted(as: "MMM d")
        } else {
            return formatted(as: "MMM d, yyyy")
        }
    }
    
    var shortFormatted: String {
        formatted(as: "MMM d")
    }
    
    var fullFormatted: String {
        formatted(as: "MMMM d, yyyy")
    }
    
    var monthYearFormatted: String {
        formatted(as: "MMMM yyyy")
    }
    
    func daysBetween(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self.startOfDay, to: date.startOfDay)
        return components.day ?? 0
    }
}

extension Int {
    var abbreviated: String {
        if self >= 1000000 {
            return String(format: "%.1fM", Double(self) / 1000000)
        } else if self >= 1000 {
            return String(format: "%.1fK", Double(self) / 1000)
        }
        return "\(self)"
    }
}

extension Double {
    var percentFormatted: String {
        String(format: "%.0f%%", self * 100)
    }
    
    var oneDecimal: String {
        String(format: "%.1f", self)
    }
}

extension String {
    var initials: String {
        let words = self.split(separator: " ")
        let initials = words.prefix(2).compactMap { $0.first }
        return String(initials).uppercased()
    }
    
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func animate(using animation: Animation = .easeInOut(duration: 0.3), _ action: @escaping () -> Void) -> some View {
        onAppear {
            withAnimation(animation) {
                action()
            }
        }
    }
}

extension Animation {
    static let smoothSpring = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let quickSpring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let gentleSpring = Animation.spring(response: 0.5, dampingFraction: 0.85)
    static let bouncy = Animation.spring(response: 0.35, dampingFraction: 0.6)
}

enum HapticManager {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

extension Array where Element == ReadingSession {
    func pagesReadOn(_ date: Date) -> Int {
        filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            .reduce(0) { $0 + $1.pagesRead }
    }
    
    func sessionsIn(month: Int, year: Int) -> [ReadingSession] {
        filter {
            $0.date.month == month && $0.date.year == year
        }
    }
    
    func totalPagesIn(month: Int, year: Int) -> Int {
        sessionsIn(month: month, year: year).reduce(0) { $0 + $1.pagesRead }
    }
}
