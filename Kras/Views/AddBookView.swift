import SwiftUI

struct AddBookView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var title = ""
    @State private var author = ""
    @State private var totalPages = ""
    @State private var selectedGenre: BookGenre = .fiction
    @State private var selectedStatus: ReadingStatus = .wantToRead
    @State private var selectedColorIndex = 0
    @State private var notes = ""
    @State private var coverImage: UIImage?
    @State private var showImageSourceSheet = false
    
    @FocusState private var focusedField: Field?
    
    private let photoManager = PhotoManager.shared
    
    private var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }
    
    enum Field: Hashable {
        case title, author, pages, notes
    }
    
    private let coverColors = [
        "6366F1", "8B5CF6", "EC4899", "F43F5E", "EF4444",
        "F97316", "EAB308", "22C55E", "14B8A6", "06B6D4",
        "3B82F6", "A855F7", "D946EF", "78716C", "1E293B"
    ]
    
    private var isFormValid: Bool {
        !title.trimmed.isEmpty && !author.trimmed.isEmpty && (Int(totalPages) ?? 0) > 0
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.adaptiveBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if isRegularWidth {
                            HStack(alignment: .top, spacing: 40) {
                                coverPreview
                                    .frame(width: 200)
                                
                                VStack(spacing: 20) {
                                    FormField(icon: "textformat", title: "Title") {
                                        TextField("Book title", text: $title)
                                            .focused($focusedField, equals: .title)
                                    }
                                    
                                    FormField(icon: "person.fill", title: "Author") {
                                        TextField("Author name", text: $author)
                                            .focused($focusedField, equals: .author)
                                    }
                                    
                                    FormField(icon: "doc.text.fill", title: "Total Pages") {
                                        TextField("Number of pages", text: $totalPages)
                                            .keyboardType(.numberPad)
                                            .focused($focusedField, equals: .pages)
                                            .onChange(of: totalPages) { _, newValue in
                                                totalPages = newValue.filter { $0.isNumber }
                                            }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.top, 20)
                            
                            HStack(alignment: .top, spacing: 20) {
                                VStack(spacing: 20) {
                                    genrePicker
                                    statusPicker
                                }
                                .frame(maxWidth: .infinity)
                                
                                VStack(spacing: 20) {
                                    if coverImage == nil {
                                        colorPicker
                                    }
                                    notesField
                                }
                                .frame(maxWidth: .infinity)
                            }
                        } else {
                            coverPreview
                            
                            VStack(spacing: 20) {
                                FormField(icon: "textformat", title: "Title") {
                                    TextField("Book title", text: $title)
                                        .focused($focusedField, equals: .title)
                                }
                                
                                FormField(icon: "person.fill", title: "Author") {
                                    TextField("Author name", text: $author)
                                        .focused($focusedField, equals: .author)
                                }
                                
                                FormField(icon: "doc.text.fill", title: "Total Pages") {
                                    TextField("Number of pages", text: $totalPages)
                                        .keyboardType(.numberPad)
                                        .focused($focusedField, equals: .pages)
                                        .onChange(of: totalPages) { _, newValue in
                                            totalPages = newValue.filter { $0.isNumber }
                                        }
                                }
                                
                                genrePicker
                                statusPicker
                                
                                if coverImage == nil {
                                    colorPicker
                                }
                                
                                notesField
                            }
                        }
                    }
                    .padding(.horizontal, isRegularWidth ? 40 : 16)
                    .padding(.vertical, 16)
                    .padding(.bottom, 100)
                    .frame(maxWidth: isRegularWidth ? 900 : .infinity)
                    .frame(maxWidth: .infinity)
                }
                
                VStack {
                    Spacer()
                    addButton
                }
            }
            .navigationTitle("Add Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .sheet(isPresented: $showImageSourceSheet) {
                ImageSourceSheet(isPresented: $showImageSourceSheet, selectedImage: $coverImage)
                    .presentationDetents([.medium])
            }
        }
    }
    
    private var coverPreview: some View {
        VStack(spacing: 12) {
            Button {
                showImageSourceSheet = true
                HapticManager.impact(.light)
            } label: {
                ZStack {
                    if let image = coverImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: isRegularWidth ? 160 : 120, height: isRegularWidth ? 235 : 175)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color.black.opacity(0.2), radius: 15, y: 8)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(hex: coverColors[selectedColorIndex]).opacity(0.4))
                                .frame(width: isRegularWidth ? 140 : 100, height: isRegularWidth ? 205 : 145)
                                .offset(y: 6)
                                .blur(radius: 15)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: coverColors[selectedColorIndex]),
                                                Color(hex: coverColors[selectedColorIndex]).opacity(0.7)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                VStack(spacing: 6) {
                                    Text(title.isEmpty ? "AB" : title.initials)
                                        .font(.system(size: isRegularWidth ? 40 : 32, weight: .bold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    Image(systemName: selectedGenre.icon)
                                        .font(.system(size: isRegularWidth ? 18 : 14))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                
                                GeometryReader { geo in
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                        .frame(width: 60, height: 60)
                                        .offset(x: -15, y: -15)
                                }
                            }
                            .frame(width: isRegularWidth ? 160 : 120, height: isRegularWidth ? 235 : 175)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(AppTheme.primaryGradient)
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: coverImage == nil ? "camera.fill" : "pencil")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .offset(x: 8, y: 8)
                        }
                    }
                    .frame(width: isRegularWidth ? 160 : 120, height: isRegularWidth ? 235 : 175)
                }
            }
            .buttonStyle(ScaleButtonStyle())
            
            Text(coverImage == nil ? "Tap to add cover photo" : "Tap to change photo")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.adaptiveSecondaryText)
        }
        .padding(.vertical, 10)
    }
    
    private var genrePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Genre", systemImage: "tag.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.adaptiveSecondaryText)
            
            if isRegularWidth {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                    ForEach(BookGenre.allCases) { genre in
                        genreButton(for: genre)
                    }
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(BookGenre.allCases) { genre in
                            genreButton(for: genre)
                        }
                    }
                }
                .scrollClipDisabled()
            }
        }
    }
    
    private func genreButton(for genre: BookGenre) -> some View {
        Button {
            withAnimation(.smoothSpring) {
                selectedGenre = genre
            }
            HapticManager.selection()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: genre.icon)
                    .font(.system(size: 12))
                Text(genre.rawValue)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(selectedGenre == genre ? .white : genre.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: isRegularWidth ? .infinity : nil)
            .background(
                selectedGenre == genre
                    ? AnyShapeStyle(genre.color)
                    : AnyShapeStyle(genre.color.opacity(0.15))
            )
            .clipShape(Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
    
    private var statusPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Status", systemImage: "bookmark.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.adaptiveSecondaryText)
            
            HStack(spacing: 10) {
                ForEach([ReadingStatus.wantToRead, .reading], id: \.self) { status in
                    Button {
                        withAnimation(.smoothSpring) {
                            selectedStatus = status
                        }
                        HapticManager.selection()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: status.icon)
                                .font(.system(size: 13))
                            Text(status.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(selectedStatus == status ? .white : status.color)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedStatus == status
                                ? AnyShapeStyle(status.color)
                                : AnyShapeStyle(status.color.opacity(0.15))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var colorPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Cover Color", systemImage: "paintpalette.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.adaptiveSecondaryText)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: isRegularWidth ? 10 : 8), spacing: 10) {
                ForEach(coverColors.indices, id: \.self) { index in
                    Button {
                        withAnimation(.smoothSpring) {
                            selectedColorIndex = index
                        }
                        HapticManager.selection()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(hex: coverColors[index]))
                                .frame(width: 36, height: 36)
                            
                            if selectedColorIndex == index {
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(Color.adaptiveCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    
    private var notesField: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Notes (optional)", systemImage: "note.text")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.adaptiveSecondaryText)
            
            TextEditor(text: $notes)
                .focused($focusedField, equals: .notes)
                .frame(minHeight: isRegularWidth ? 120 : 80)
                .padding(12)
                .scrollContentBackground(.hidden)
                .background(Color.adaptiveCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.adaptiveDivider, lineWidth: 1)
                )
        }
    }
    
    private var addButton: some View {
        Button {
            addBook()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18))
                Text("Add Book")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: isRegularWidth ? 400 : .infinity)
            .padding(.vertical, 16)
            .background(
                isFormValid
                    ? AppTheme.primaryGradient
                    : LinearGradient(colors: [Color.gray.opacity(0.5)], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isFormValid)
        .padding(.horizontal, isRegularWidth ? 40 : 16)
        .padding(.bottom, 20)
        .background(
            LinearGradient(
                colors: [Color.adaptiveBackground.opacity(0), Color.adaptiveBackground],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 100)
            .allowsHitTesting(false)
        )
    }
    
    private func addBook() {
        let bookId = UUID()
        var imageFilename: String? = nil
        
        if let image = coverImage {
            imageFilename = photoManager.saveImage(image, forBookId: bookId)
        }
        
        let book = Book(
            id: bookId,
            title: title.trimmed,
            author: author.trimmed,
            totalPages: Int(totalPages) ?? 0,
            currentPage: 0,
            genre: selectedGenre,
            status: selectedStatus,
            coverColorHex: coverColors[selectedColorIndex],
            coverImageFilename: imageFilename,
            notes: notes.trimmed,
            dateStarted: selectedStatus == .reading ? Date() : nil
        )
        
        dataManager.addBook(book)
        dismiss()
    }
}

struct FormField<Content: View>: View {
    let icon: String
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.adaptiveSecondaryText)
            
            content
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.adaptivePrimaryText)
                .padding(14)
                .background(Color.adaptiveCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.adaptiveDivider, lineWidth: 1)
                )
        }
    }
}
