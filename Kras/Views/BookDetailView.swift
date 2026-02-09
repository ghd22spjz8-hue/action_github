import SwiftUI

struct BookDetailView: View {
    @State var book: Book
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var showUpdateProgress = false
    @State private var showEditBook = false
    @State private var showDeleteConfirmation = false
    @State private var showRatingSheet = false
    @State private var animateHeader = false
    @State private var coverImage: UIImage?
    
    private let photoManager = PhotoManager.shared
    
    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        NavigationStack {
            mainContent
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .sheet(isPresented: $showUpdateProgress) {
                    UpdateProgressSheet(book: book, dataManager: dataManager)
                }
                .sheet(isPresented: $showEditBook) {
                    EditBookView(book: $book, dataManager: dataManager)
                }
                .sheet(isPresented: $showRatingSheet) {
                    RatingSheet(book: $book, dataManager: dataManager)
                }
                .alert("Delete Book", isPresented: $showDeleteConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        dataManager.deleteBook(book)
                        dismiss()
                    }
                } message: {
                    Text("Are you sure you want to delete '\(book.title)'? This action cannot be undone.")
                }
                .onAppear {
                    withAnimation(.easeOut(duration: 0.6)) {
                        animateHeader = true
                    }
                    loadCoverImage()
                }
                .onChange(of: dataManager.books) { _, newBooks in
                    if let updated = newBooks.first(where: { $0.id == book.id }) {
                        book = updated
                    }
                }
        }
    }
    
    private var mainContent: some View {
        ZStack {
            backgroundGradient
            scrollContent
        }
    }
    
    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                quickActions
                
                if isRegularWidth {
                    HStack(alignment: .top, spacing: 20) {
                        VStack(spacing: 24) {
                            if book.status == .reading {
                                progressSection
                            }
                            detailsSection
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(spacing: 24) {
                            if !book.readingSessions.isEmpty {
                                sessionsSection
                            }
                            if !book.notes.isEmpty {
                                notesSection
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                } else {
                    if book.status == .reading {
                        progressSection
                    }
                    detailsSection
                    
                    if !book.readingSessions.isEmpty {
                        sessionsSection
                    }
                    
                    if !book.notes.isEmpty {
                        notesSection
                    }
                }
                
                dangerZone
            }
            .padding(.horizontal, isRegularWidth ? 40 : 16)
            .padding(.bottom, 40)
            .frame(maxWidth: isRegularWidth ? 900 : .infinity)
            .frame(maxWidth: .infinity)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.adaptiveSecondaryText)
            }
        }
        
        ToolbarItem(placement: .primaryAction) {
            Button {
                showEditBook = true
            } label: {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 28))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(AppTheme.primary)
            }
        }
    }
    
    private var backgroundGradient: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    book.coverColor.opacity(colorScheme == .dark ? 0.3 : 0.2),
                    Color.adaptiveBackground
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: isRegularWidth ? 400 : 350)
            
            Color.adaptiveBackground
        }
        .ignoresSafeArea()
    }
    
    private func loadCoverImage() {
        if let filename = book.coverImageFilename {
            coverImage = photoManager.loadImage(filename: filename)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(book.coverColor.opacity(0.5))
                    .frame(width: isRegularWidth ? 170 : 140, height: isRegularWidth ? 240 : 200)
                    .offset(y: 8)
                    .blur(radius: 20)
                
                if let image = coverImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: isRegularWidth ? 180 : 150, height: isRegularWidth ? 260 : 220)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [book.coverColor, book.coverColor.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        VStack(spacing: 8) {
                            Text(book.title.initials)
                                .font(.system(size: isRegularWidth ? 56 : 48, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Image(systemName: book.genre.icon)
                                .font(.system(size: isRegularWidth ? 24 : 20))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        GeometryReader { geo in
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 100, height: 100)
                                .offset(x: -30, y: -30)
                            
                            Circle()
                                .fill(Color.white.opacity(0.08))
                                .frame(width: 60, height: 60)
                                .offset(x: geo.size.width - 20, y: geo.size.height - 20)
                        }
                    }
                    .frame(width: isRegularWidth ? 180 : 150, height: isRegularWidth ? 260 : 220)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .scaleEffect(animateHeader ? 1 : 0.8)
            .opacity(animateHeader ? 1 : 0)
            
            VStack(spacing: 8) {
                Text(book.title)
                    .font(.system(size: isRegularWidth ? 28 : 24, weight: .bold, design: .rounded))
                    .foregroundColor(.adaptivePrimaryText)
                    .multilineTextAlignment(.center)
                
                Text(book.author)
                    .font(.system(size: isRegularWidth ? 19 : 17, weight: .medium))
                    .foregroundColor(.adaptiveSecondaryText)
                
                HStack(spacing: 10) {
                    HStack(spacing: 4) {
                        Image(systemName: book.genre.icon)
                            .font(.system(size: 11))
                        Text(book.genre.rawValue)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(book.genre.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(book.genre.color.opacity(0.15))
                    .clipShape(Capsule())
                    
                    HStack(spacing: 4) {
                        Image(systemName: book.status.icon)
                            .font(.system(size: 11))
                        Text(book.status.rawValue)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(book.status.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(book.status.color.opacity(0.15))
                    .clipShape(Capsule())
                }
                .padding(.top, 4)
                
                if let rating = book.rating {
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= rating ? "star.fill" : "star")
                                .font(.system(size: 16))
                                .foregroundColor(index <= rating ? .yellow : .adaptiveTertiaryText)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .opacity(animateHeader ? 1 : 0)
            .offset(y: animateHeader ? 0 : 20)
        }
        .padding(.top, 20)
    }
    
    private var quickActions: some View {
        HStack(spacing: 12) {
            if book.status == .reading {
                ActionButton(
                    icon: "plus.circle.fill",
                    title: "Update",
                    color: AppTheme.primary
                ) {
                    showUpdateProgress = true
                }
            }
            
            if book.status == .wantToRead {
                ActionButton(
                    icon: "book.fill",
                    title: "Start",
                    color: .blue
                ) {
                    dataManager.startReading(book)
                }
            }
            
            if book.status == .reading {
                ActionButton(
                    icon: "checkmark.circle.fill",
                    title: "Finish",
                    color: .green
                ) {
                    showRatingSheet = true
                }
            }
            
            if book.status == .finished {
                ActionButton(
                    icon: "star.fill",
                    title: "Rate",
                    color: .yellow
                ) {
                    showRatingSheet = true
                }
            }
        }
        .frame(maxWidth: isRegularWidth ? 500 : .infinity)
    }
    
    private var progressSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Progress")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.adaptivePrimaryText)
                
                Spacer()
                
                Text("\(book.progressPercent)%")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primary)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.adaptiveDivider)
                        .frame(height: 16)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppTheme.primaryGradient)
                        .frame(width: geo.size.width * book.progress, height: 16)
                }
            }
            .frame(height: 16)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(book.currentPage)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptivePrimaryText)
                    Text("pages read")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.adaptiveSecondaryText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(book.pagesRemaining)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptivePrimaryText)
                    Text("pages left")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.adaptiveSecondaryText)
                }
            }
        }
        .padding(16)
        .background(Color.adaptiveCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .cardShadow()
    }
    
    private var detailsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Details")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.adaptivePrimaryText)
                Spacer()
            }
            
            VStack(spacing: 12) {
                DetailRow(label: "Total Pages", value: "\(book.totalPages)")
                DetailRow(label: "Added", value: book.dateAdded.relativeFormatted)
                
                if let started = book.dateStarted {
                    DetailRow(label: "Started", value: started.relativeFormatted)
                }
                
                if let finished = book.dateFinished {
                    DetailRow(label: "Finished", value: finished.relativeFormatted)
                }
                
                if !book.readingSessions.isEmpty {
                    DetailRow(label: "Reading Sessions", value: "\(book.readingSessions.count)")
                    DetailRow(label: "Avg Pages/Session", value: "\(Int(book.averagePagesPerSession))")
                }
            }
        }
        .padding(16)
        .background(Color.adaptiveCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .cardShadow()
    }
    
    private var sessionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Reading History")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.adaptivePrimaryText)
                Spacer()
            }
            
            ForEach(book.readingSessions.sorted(by: { $0.date > $1.date }).prefix(5)) { session in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.date.relativeFormatted)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.adaptivePrimaryText)
                        
                        if let note = session.note {
                            Text(note)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.adaptiveSecondaryText)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    Text("+\(session.pagesRead) pages")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.success)
                }
                .padding(.vertical, 8)
                
                if session.id != book.readingSessions.sorted(by: { $0.date > $1.date }).prefix(5).last?.id {
                    Divider()
                }
            }
        }
        .padding(16)
        .background(Color.adaptiveCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .cardShadow()
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.adaptivePrimaryText)
            
            Text(book.notes)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.adaptiveSecondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.adaptiveCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .cardShadow()
    }
    
    private var dangerZone: some View {
        Button {
            showDeleteConfirmation = true
        } label: {
            HStack {
                Image(systemName: "trash")
                    .font(.system(size: 15, weight: .semibold))
                Text("Delete Book")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.red)
            .frame(maxWidth: isRegularWidth ? 400 : .infinity)
            .padding(.vertical, 14)
            .background(Color.red.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 20)
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
            HapticManager.impact(.medium)
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.adaptivePrimaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.adaptiveCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .cardShadow()
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.adaptiveSecondaryText)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.adaptivePrimaryText)
        }
    }
}

struct RatingSheet: View {
    @Binding var book: Book
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var selectedRating: Int = 0
    
    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 12) {
                    Text("How would you rate")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.adaptiveSecondaryText)
                    
                    Text(book.title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptivePrimaryText)
                        .multilineTextAlignment(.center)
                }
                
                HStack(spacing: isRegularWidth ? 20 : 12) {
                    ForEach(1...5, id: \.self) { index in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                selectedRating = index
                            }
                            HapticManager.impact(.light)
                        } label: {
                            Image(systemName: index <= selectedRating ? "star.fill" : "star")
                                .font(.system(size: isRegularWidth ? 56 : 44))
                                .foregroundColor(index <= selectedRating ? .yellow : .adaptiveTertiaryText)
                                .scaleEffect(index <= selectedRating ? 1.1 : 1)
                        }
                    }
                }
                .padding(.vertical, 20)
                
                if selectedRating > 0 {
                    Text(ratingLabel)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.adaptiveSecondaryText)
                }
                
                Spacer()
                
                Button {
                    saveRating()
                } label: {
                    Text(book.status == .reading ? "Finish & Save Rating" : "Save Rating")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: isRegularWidth ? 400 : .infinity)
                        .padding(.vertical, 16)
                        .background(
                            selectedRating > 0
                                ? AppTheme.primaryGradient
                                : LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(selectedRating == 0)
                .padding(.horizontal, isRegularWidth ? 100 : 16)
            }
            .padding()
            .background(Color.adaptiveBackground.ignoresSafeArea())
            .navigationTitle("Rate Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") {
                        if book.status == .reading {
                            dataManager.finishBook(book, rating: nil)
                        }
                        dismiss()
                    }
                }
            }
            .onAppear {
                selectedRating = book.rating ?? 0
            }
        }
    }
    
    private var ratingLabel: String {
        switch selectedRating {
        case 1: return "Not for me"
        case 2: return "It was okay"
        case 3: return "Good read"
        case 4: return "Really enjoyed it"
        case 5: return "Absolutely loved it!"
        default: return ""
        }
    }
    
    private func saveRating() {
        if book.status == .reading {
            dataManager.finishBook(book, rating: selectedRating)
        } else {
            book.rating = selectedRating
            dataManager.updateBook(book)
        }
        HapticManager.notification(.success)
        dismiss()
    }
}

struct EditBookView: View {
    @Binding var book: Book
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var title: String = ""
    @State private var author: String = ""
    @State private var totalPages: String = ""
    @State private var selectedGenre: BookGenre = .fiction
    @State private var notes: String = ""
    @State private var coverImage: UIImage?
    @State private var showImageSourceSheet = false
    @State private var imageChanged = false
    
    private let photoManager = PhotoManager.shared
    
    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Cover Photo") {
                    HStack {
                        Spacer()
                        Button {
                            showImageSourceSheet = true
                        } label: {
                            ZStack {
                                if let image = coverImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: isRegularWidth ? 100 : 80, height: isRegularWidth ? 145 : 115)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                } else {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(
                                                LinearGradient(
                                                    colors: [book.coverColor, book.coverColor.opacity(0.7)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: isRegularWidth ? 100 : 80, height: isRegularWidth ? 145 : 115)
                                        
                                        Text(book.title.initials)
                                            .font(.system(size: isRegularWidth ? 28 : 24, weight: .bold, design: .rounded))
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                }
                                
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        ZStack {
                                            Circle()
                                                .fill(AppTheme.primaryGradient)
                                                .frame(width: 28, height: 28)
                                            
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white)
                                        }
                                        .offset(x: 6, y: 6)
                                    }
                                }
                                .frame(width: isRegularWidth ? 100 : 80, height: isRegularWidth ? 145 : 115)
                            }
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                }
                
                Section("Book Details") {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    TextField("Total Pages", text: $totalPages)
                        .keyboardType(.numberPad)
                }
                
                Section("Genre") {
                    Picker("Genre", selection: $selectedGenre) {
                        ForEach(BookGenre.allCases) { genre in
                            HStack {
                                Image(systemName: genre.icon)
                                Text(genre.rawValue)
                            }
                            .tag(genre)
                        }
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: isRegularWidth ? 150 : 100)
                }
            }
            .navigationTitle("Edit Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(title.isEmpty || author.isEmpty)
                }
            }
            .onAppear {
                title = book.title
                author = book.author
                totalPages = "\(book.totalPages)"
                selectedGenre = book.genre
                notes = book.notes
                loadExistingCover()
            }
            .sheet(isPresented: $showImageSourceSheet) {
                ImageSourceSheet(isPresented: $showImageSourceSheet, selectedImage: $coverImage)
                    .presentationDetents([.medium])
                    .onChange(of: coverImage) { _, _ in
                        imageChanged = true
                    }
            }
        }
    }
    
    private func loadExistingCover() {
        if let filename = book.coverImageFilename {
            coverImage = photoManager.loadImage(filename: filename)
        }
    }
    
    private func saveChanges() {
        book.title = title
        book.author = author
        book.totalPages = Int(totalPages) ?? book.totalPages
        book.genre = selectedGenre
        book.notes = notes
        
        if imageChanged {
            if let oldFilename = book.coverImageFilename {
                photoManager.deleteImage(filename: oldFilename)
            }
            
            if let newImage = coverImage {
                book.coverImageFilename = photoManager.saveImage(newImage, forBookId: book.id)
            } else {
                book.coverImageFilename = nil
            }
        }
        
        dataManager.updateBook(book)
        dismiss()
    }
}
