import SwiftUI
import Combine

@MainActor
class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var books: [Book] = []
    @Published var readingGoal: ReadingGoal = .default
    @Published var dailyReadingGoal: Int = 30
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    
    var currentlyReading: [Book] {
        books.filter { $0.status == .reading }
    }
    
    var wantToRead: [Book] {
        books.filter { $0.status == .wantToRead }
    }
    
    var finishedBooks: [Book] {
        books.filter { $0.status == .finished }
    }
    
    var abandonedBooks: [Book] {
        books.filter { $0.status == .abandoned }
    }
    
    var booksFinishedThisYear: [Book] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return finishedBooks.filter { $0.dateFinished?.year == currentYear }
    }
    
    var totalPagesReadThisYear: Int {
        booksFinishedThisYear.reduce(0) { $0 + $1.totalPages }
    }
    
    var totalPagesReadAllTime: Int {
        finishedBooks.reduce(0) { $0 + $1.totalPages }
    }
    
    var goalProgress: Double {
        guard readingGoal.targetBooks > 0 else { return 0 }
        return Double(booksFinishedThisYear.count) / Double(readingGoal.targetBooks)
    }
    
    var pagesGoalProgress: Double {
        guard readingGoal.targetPages > 0 else { return 0 }
        return Double(totalPagesReadThisYear) / Double(readingGoal.targetPages)
    }
    
    var pagesReadToday: Int {
        let today = Date().startOfDay
        return books.flatMap { $0.readingSessions }
            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.pagesRead }
    }
    
    var pagesReadThisWeek: Int {
        let weekStart = Date().startOfWeek
        return books.flatMap { $0.readingSessions }
            .filter { $0.date >= weekStart }
            .reduce(0) { $0 + $1.pagesRead }
    }
    
    var pagesReadThisMonth: Int {
        let monthStart = Date().startOfMonth
        return books.flatMap { $0.readingSessions }
            .filter { $0.date >= monthStart }
            .reduce(0) { $0 + $1.pagesRead }
    }
    
    var averagePagesPerDay: Double {
        let sessions = books.flatMap { $0.readingSessions }
        guard !sessions.isEmpty else { return 0 }
        
        let sortedSessions = sessions.sorted { $0.date < $1.date }
        guard let firstDate = sortedSessions.first?.date else { return 0 }
        
        let daysSinceStart = max(1, firstDate.daysBetween(Date()))
        let totalPages = sessions.reduce(0) { $0 + $1.pagesRead }
        
        return Double(totalPages) / Double(daysSinceStart)
    }
    
    var booksByGenre: [BookGenre: [Book]] {
        Dictionary(grouping: books, by: { $0.genre })
    }
    
    var favoriteGenre: BookGenre? {
        booksByGenre.max(by: { $0.value.count < $1.value.count })?.key
    }
    
    private enum Keys {
        static let books = "kras_books"
        static let readingGoal = "kras_reading_goal"
        static let dailyReadingGoal = "kras_daily_reading_goal"
        static let currentStreak = "kras_current_streak"
        static let longestStreak = "kras_longest_streak"
        static let lastReadDate = "kras_last_read_date"
    }
    
    private init() {
        loadData()
        calculateStreak()
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: Keys.books),
           let decoded = try? JSONDecoder().decode([Book].self, from: data) {
            books = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: Keys.readingGoal),
           let decoded = try? JSONDecoder().decode(ReadingGoal.self, from: data) {
            readingGoal = decoded
        }
        
        dailyReadingGoal = UserDefaults.standard.integer(forKey: Keys.dailyReadingGoal)
        if dailyReadingGoal == 0 { dailyReadingGoal = 30 }
        
        currentStreak = UserDefaults.standard.integer(forKey: Keys.currentStreak)
        longestStreak = UserDefaults.standard.integer(forKey: Keys.longestStreak)
    }
    
    private func saveBooks() {
        if let encoded = try? JSONEncoder().encode(books) {
            UserDefaults.standard.set(encoded, forKey: Keys.books)
        }
    }
    
    private func saveReadingGoal() {
        if let encoded = try? JSONEncoder().encode(readingGoal) {
            UserDefaults.standard.set(encoded, forKey: Keys.readingGoal)
        }
    }
    
    private func saveStreak() {
        UserDefaults.standard.set(currentStreak, forKey: Keys.currentStreak)
        UserDefaults.standard.set(longestStreak, forKey: Keys.longestStreak)
    }
    
    func addBook(_ book: Book) {
        books.append(book)
        saveBooks()
        HapticManager.notification(.success)
    }
    
    func updateBook(_ book: Book) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = book
            saveBooks()
        }
    }
    
    func deleteBook(_ book: Book) {
        books.removeAll { $0.id == book.id }
        saveBooks()
        HapticManager.impact(.medium)
    }
    
    func deleteBooks(at offsets: IndexSet, from bookList: [Book]) {
        for index in offsets {
            let book = bookList[index]
            books.removeAll { $0.id == book.id }
        }
        saveBooks()
    }
    
    func updateProgress(for book: Book, newPage: Int, minutesSpent: Int? = nil, note: String? = nil) {
        guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }
        
        let pagesRead = max(0, newPage - books[index].currentPage)
        
        if pagesRead > 0 {
            let session = ReadingSession(
                pagesRead: pagesRead,
                minutesSpent: minutesSpent,
                note: note
            )
            books[index].readingSessions.append(session)
            updateStreak()
        }
        
        books[index].currentPage = min(newPage, books[index].totalPages)
        
        if books[index].currentPage >= books[index].totalPages {
            books[index].status = .finished
            books[index].dateFinished = Date()
            HapticManager.notification(.success)
        } else if books[index].currentPage > 0 && books[index].status == .wantToRead {
            books[index].status = .reading
            books[index].dateStarted = books[index].dateStarted ?? Date()
        }
        
        saveBooks()
        HapticManager.impact(.light)
    }
    
    func startReading(_ book: Book) {
        guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }
        books[index].status = .reading
        books[index].dateStarted = Date()
        saveBooks()
        HapticManager.impact(.medium)
    }
    
    func finishBook(_ book: Book, rating: Int? = nil) {
        guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }
        books[index].status = .finished
        books[index].currentPage = books[index].totalPages
        books[index].dateFinished = Date()
        books[index].rating = rating
        saveBooks()
        HapticManager.notification(.success)
    }
    
    func abandonBook(_ book: Book) {
        guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }
        books[index].status = .abandoned
        saveBooks()
    }
    
    func updateReadingGoal(books: Int? = nil, pages: Int? = nil) {
        if let books = books {
            readingGoal.targetBooks = books
        }
        if let pages = pages {
            readingGoal.targetPages = pages
        }
        saveReadingGoal()
    }
    
    func updateDailyGoal(_ pages: Int) {
        dailyReadingGoal = pages
        UserDefaults.standard.set(pages, forKey: Keys.dailyReadingGoal)
    }
    
    private func calculateStreak() {
        let sessions = books.flatMap { $0.readingSessions }
            .sorted { $0.date > $1.date }
        
        guard !sessions.isEmpty else {
            currentStreak = 0
            return
        }
        
        var streak = 0
        var currentDate = Date().startOfDay
        
        let readToday = sessions.contains { Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
        
        if !readToday {
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        while true {
            let readOnDate = sessions.contains { Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
            
            if readOnDate {
                streak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        currentStreak = streak
        longestStreak = max(longestStreak, currentStreak)
        saveStreak()
    }
    
    private func updateStreak() {
        calculateStreak()
    }
    
    func readingActivityForMonth(_ date: Date) -> [Date: Int] {
        var activity: [Date: Int] = [:]
        
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        for day in range {
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            
            if let dayDate = calendar.date(from: components) {
                let pages = books.flatMap { $0.readingSessions }
                    .filter { calendar.isDate($0.date, inSameDayAs: dayDate) }
                    .reduce(0) { $0 + $1.pagesRead }
                activity[dayDate] = pages
            }
        }
        
        return activity
    }
    
    func monthlyStats(for months: Int = 6) -> [(month: String, pages: Int)] {
        var stats: [(String, Int)] = []
        let calendar = Calendar.current
        
        for i in 0..<months {
            if let date = calendar.date(byAdding: .month, value: -i, to: Date()) {
                let monthName = date.formatted(as: "MMM")
                let pages = books.flatMap { $0.readingSessions }
                    .filter { calendar.isDate($0.date, equalTo: date, toGranularity: .month) }
                    .reduce(0) { $0 + $1.pagesRead }
                stats.append((monthName, pages))
            }
        }
        
        return stats.reversed()
    }
}
