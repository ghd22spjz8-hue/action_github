import SwiftUI

struct LibraryView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var searchText = ""
    @State private var selectedFilter: LibraryFilter = .all
    @State private var viewMode: ViewMode = .grid
    @State private var showAddBook = false
    @State private var selectedBook: Book?
    @State private var showUpdateProgress = false
    @State private var bookToUpdate: Book?
    
    @Namespace private var animation
    
    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }
    
    private var gridColumns: [GridItem] {
        if isRegularWidth {
            return [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ]
        } else {
            return [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ]
        }
    }
    
    enum ViewMode: String, CaseIterable {
        case grid = "square.grid.2x2"
        case list = "list.bullet"
    }
    
    enum LibraryFilter: String, CaseIterable {
        case all = "All"
        case reading = "Reading"
        case wantToRead = "Want to Read"
        case finished = "Finished"
        
        var icon: String {
            switch self {
            case .all: return "books.vertical"
            case .reading: return "book.fill"
            case .wantToRead: return "bookmark"
            case .finished: return "checkmark.circle"
            }
        }
    }
    
    private var filteredBooks: [Book] {
        var books: [Book]
        
        switch selectedFilter {
        case .all:
            books = dataManager.books
        case .reading:
            books = dataManager.currentlyReading
        case .wantToRead:
            books = dataManager.wantToRead
        case .finished:
            books = dataManager.finishedBooks
        }
        
        if searchText.isEmpty {
            return books
        } else {
            return books.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.author.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.adaptiveBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("📚")
                                    .font(.title)
                                Text("Library")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                    .foregroundColor(.adaptivePrimaryText)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                Button {
                                    withAnimation(.smoothSpring) {
                                        viewMode = viewMode == .grid ? .list : .grid
                                    }
                                    HapticManager.selection()
                                } label: {
                                    Image(systemName: viewMode.rawValue)
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.adaptivePrimaryText)
                                        .padding(10)
                                        .background(Color.adaptiveCardBackground)
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                                
                                Button {
                                    showAddBook = true
                                    HapticManager.impact(.light)
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundStyle(AppTheme.primaryGradient)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        if selectedFilter == .all || selectedFilter == .reading {
                            currentlyReadingSection
                        }
                        
                        filterTabs
                        
                        searchBar
                        
                        if filteredBooks.isEmpty {
                            emptyState
                        } else {
                            booksContent
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
            .sheet(isPresented: $showAddBook) {
                AddBookView(dataManager: dataManager)
            }
            .sheet(item: $selectedBook) { book in
                BookDetailView(book: book, dataManager: dataManager)
            }
            .sheet(item: $bookToUpdate) { book in
                UpdateProgressSheet(book: book, dataManager: dataManager)
            }
        }
    }
    
    @ViewBuilder
    private var currentlyReadingSection: some View {
        if !dataManager.currentlyReading.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Currently Reading")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptivePrimaryText)
                    
                    Spacer()
                    
                    Text("\(dataManager.currentlyReading.count) books")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.adaptiveSecondaryText)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(dataManager.currentlyReading) { book in
                            CurrentlyReadingCard(
                                book: book,
                                onTap: { selectedBook = book },
                                onUpdateProgress: { bookToUpdate = book }
                            )
                            .frame(width: isRegularWidth ? 380 : 320)
                        }
                    }
                }
                .scrollClipDisabled()
            }
            .padding(.top, 8)
        }
    }
    
    private var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(LibraryFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        icon: filter.icon,
                        isSelected: selectedFilter == filter,
                        animation: animation
                    ) {
                        withAnimation(.smoothSpring) {
                            selectedFilter = filter
                        }
                        HapticManager.selection()
                    }
                }
            }
        }
        .scrollClipDisabled()
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.adaptiveSecondaryText)
            
            TextField("Search books...", text: $searchText)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.adaptivePrimaryText)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    hideKeyboard()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.adaptiveTertiaryText)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.adaptiveCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.adaptiveDivider, lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private var booksContent: some View {
        if viewMode == .grid {
            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(filteredBooks) { book in
                    BookCardView(book: book) {
                        selectedBook = book
                    }
                }
            }
        } else {
            if isRegularWidth {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 12) {
                    ForEach(filteredBooks) { book in
                        BookListRowView(book: book) {
                            selectedBook = book
                        }
                    }
                }
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredBooks) { book in
                        BookListRowView(book: book) {
                            selectedBook = book
                        }
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        EmptyStateView(
            icon: searchText.isEmpty ? "book.closed" : "magnifyingglass",
            title: searchText.isEmpty ? "No Books Yet" : "No Results",
            message: searchText.isEmpty
                ? "Start your reading journey by adding your first book"
                : "Try a different search term",
            buttonTitle: searchText.isEmpty ? "Add Book" : nil,
            buttonAction: searchText.isEmpty ? { showAddBook = true } : nil
        )
        .padding(.top, 40)
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let animation: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : .adaptiveSecondaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isSelected {
                        Capsule()
                            .fill(AppTheme.primaryGradient)
                            .matchedGeometryEffect(id: "FILTER_BG", in: animation)
                    } else {
                        Capsule()
                            .fill(Color.adaptiveCardBackground)
                            .overlay(
                                Capsule()
                                    .stroke(Color.adaptiveDivider, lineWidth: 1)
                            )
                    }
                }
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct UpdateProgressSheet: View {
    let book: Book
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var currentPage: Int
    @State private var minutesSpent: String = ""
    @State private var note: String = ""
    
    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }
    
    init(book: Book, dataManager: DataManager) {
        self.book = book
        self.dataManager = dataManager
        self._currentPage = State(initialValue: book.currentPage)
    }
    
    private var pagesRead: Int {
        max(0, currentPage - book.currentPage)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.adaptiveBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        LinearGradient(
                                            colors: [book.coverColor, book.coverColor.opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 60, height: 85)
                                
                                Text(book.title.initials)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(book.title)
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.adaptivePrimaryText)
                                
                                Text(book.author)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.adaptiveSecondaryText)
                                
                                Text("Currently on page \(book.currentPage)")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.adaptiveTertiaryText)
                            }
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(Color.adaptiveCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                        
                        VStack(spacing: 16) {
                            HStack {
                                Text("Current Page")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.adaptivePrimaryText)
                                
                                Spacer()
                                
                                Text("\(currentPage) / \(book.totalPages)")
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                                    .foregroundColor(AppTheme.primary)
                            }
                            
                            Slider(
                                value: Binding(
                                    get: { Double(currentPage) },
                                    set: { currentPage = Int($0) }
                                ),
                                in: Double(book.currentPage)...Double(book.totalPages),
                                step: 1
                            )
                            .tint(AppTheme.primary)
                            
                            if pagesRead > 0 {
                                Text("+\(pagesRead) pages read!")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(AppTheme.success)
                            }
                        }
                        .padding(16)
                        .background(Color.adaptiveCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick Add")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.adaptiveSecondaryText)
                            
                            HStack(spacing: 10) {
                                ForEach([5, 10, 20, 50], id: \.self) { pages in
                                    Button {
                                        withAnimation(.smoothSpring) {
                                            currentPage = min(book.totalPages, currentPage + pages)
                                        }
                                        HapticManager.impact(.light)
                                    } label: {
                                        Text("+\(pages)")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(AppTheme.primary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(AppTheme.primary.opacity(0.1))
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Add a note (optional)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.adaptiveSecondaryText)
                            
                            TextField("What did you think about this section?", text: $note, axis: .vertical)
                                .lineLimit(3...5)
                                .padding(12)
                                .background(Color.adaptiveCardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.adaptiveDivider, lineWidth: 1)
                                )
                        }
                    }
                    .padding()
                    .frame(maxWidth: isRegularWidth ? 600 : .infinity)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Update Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProgress()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(pagesRead > 0 ? AppTheme.primary : .adaptiveTertiaryText)
                    .disabled(pagesRead == 0)
                }
            }
        }
    }
    
    private func saveProgress() {
        let minutes = Int(minutesSpent)
        dataManager.updateProgress(
            for: book,
            newPage: currentPage,
            minutesSpent: minutes,
            note: note.isEmpty ? nil : note
        )
        dismiss()
    }
}
