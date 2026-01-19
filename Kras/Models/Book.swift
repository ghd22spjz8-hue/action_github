import SwiftUI

enum ReadingStatus: String, Codable, CaseIterable {
    case wantToRead = "Want to Read"
    case reading = "Reading"
    case finished = "Finished"
    case abandoned = "Abandoned"
    
    var icon: String {
        switch self {
        case .wantToRead: return "bookmark"
        case .reading: return "book.fill"
        case .finished: return "checkmark.circle.fill"
        case .abandoned: return "xmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .wantToRead: return .orange
        case .reading: return .blue
        case .finished: return .green
        case .abandoned: return .gray
        }
    }
}

enum BookGenre: String, Codable, CaseIterable, Identifiable {
    case fiction = "Fiction"
    case nonFiction = "Non-Fiction"
    case mystery = "Mystery"
    case sciFi = "Sci-Fi"
    case fantasy = "Fantasy"
    case romance = "Romance"
    case thriller = "Thriller"
    case biography = "Biography"
    case selfHelp = "Self-Help"
    case business = "Business"
    case history = "History"
    case science = "Science"
    case poetry = "Poetry"
    case other = "Other"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .fiction: return "text.book.closed"
        case .nonFiction: return "doc.text"
        case .mystery: return "magnifyingglass"
        case .sciFi: return "sparkles"
        case .fantasy: return "wand.and.stars"
        case .romance: return "heart.fill"
        case .thriller: return "bolt.fill"
        case .biography: return "person.fill"
        case .selfHelp: return "lightbulb.fill"
        case .business: return "chart.line.uptrend.xyaxis"
        case .history: return "clock.fill"
        case .science: return "atom"
        case .poetry: return "quote.opening"
        case .other: return "ellipsis.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .fiction: return Color(hex: "6366F1")
        case .nonFiction: return Color(hex: "8B5CF6")
        case .mystery: return Color(hex: "EC4899")
        case .sciFi: return Color(hex: "06B6D4")
        case .fantasy: return Color(hex: "A855F7")
        case .romance: return Color(hex: "F43F5E")
        case .thriller: return Color(hex: "EF4444")
        case .biography: return Color(hex: "F97316")
        case .selfHelp: return Color(hex: "EAB308")
        case .business: return Color(hex: "22C55E")
        case .history: return Color(hex: "78716C")
        case .science: return Color(hex: "3B82F6")
        case .poetry: return Color(hex: "D946EF")
        case .other: return Color(hex: "64748B")
        }
    }
}

struct Book: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var author: String
    var totalPages: Int
    var currentPage: Int
    var genre: BookGenre
    var status: ReadingStatus
    var coverColorHex: String
    var coverImageFilename: String?
    var rating: Int?
    var notes: String
    var dateAdded: Date
    var dateStarted: Date?
    var dateFinished: Date?
    var readingSessions: [ReadingSession]
    
    init(
        id: UUID = UUID(),
        title: String,
        author: String,
        totalPages: Int,
        currentPage: Int = 0,
        genre: BookGenre = .fiction,
        status: ReadingStatus = .wantToRead,
        coverColorHex: String? = nil,
        coverImageFilename: String? = nil,
        rating: Int? = nil,
        notes: String = "",
        dateAdded: Date = Date(),
        dateStarted: Date? = nil,
        dateFinished: Date? = nil,
        readingSessions: [ReadingSession] = []
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.totalPages = totalPages
        self.currentPage = currentPage
        self.genre = genre
        self.status = status
        self.coverColorHex = coverColorHex ?? Self.randomCoverColor()
        self.coverImageFilename = coverImageFilename
        self.rating = rating
        self.notes = notes
        self.dateAdded = dateAdded
        self.dateStarted = dateStarted
        self.dateFinished = dateFinished
        self.readingSessions = readingSessions
    }
    
    var hasCoverImage: Bool {
        coverImageFilename != nil
    }
    
    var progress: Double {
        guard totalPages > 0 else { return 0 }
        return Double(currentPage) / Double(totalPages)
    }
    
    var progressPercent: Int {
        Int(progress * 100)
    }
    
    var pagesRemaining: Int {
        max(0, totalPages - currentPage)
    }
    
    var coverColor: Color {
        Color(hex: coverColorHex)
    }
    
    var isFinished: Bool {
        status == .finished
    }
    
    var totalPagesRead: Int {
        readingSessions.reduce(0) { $0 + $1.pagesRead }
    }
    
    var averagePagesPerSession: Double {
        guard !readingSessions.isEmpty else { return 0 }
        return Double(totalPagesRead) / Double(readingSessions.count)
    }
    
    static func randomCoverColor() -> String {
        let colors = [
            "6366F1", "8B5CF6", "EC4899", "F43F5E", "EF4444",
            "F97316", "EAB308", "22C55E", "14B8A6", "06B6D4",
            "3B82F6", "A855F7", "D946EF", "78716C", "1E293B"
        ]
        return colors.randomElement() ?? "6366F1"
    }
}

struct ReadingSession: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let pagesRead: Int
    let minutesSpent: Int?
    let note: String?
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        pagesRead: Int,
        minutesSpent: Int? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.date = date
        self.pagesRead = pagesRead
        self.minutesSpent = minutesSpent
        self.note = note
    }
}

struct ReadingGoal: Codable, Equatable {
    var year: Int
    var targetBooks: Int
    var targetPages: Int
    
    init(year: Int = Calendar.current.component(.year, from: Date()), targetBooks: Int = 12, targetPages: Int = 5000) {
        self.year = year
        self.targetBooks = targetBooks
        self.targetPages = targetPages
    }
    
    static let `default` = ReadingGoal()
}
