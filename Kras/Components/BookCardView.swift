import SwiftUI

struct BookCardView: View {
    let book: Book
    var onTap: (() -> Void)? = nil
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var coverImage: UIImage?
    
    private let photoManager = PhotoManager.shared
    
    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 0) {
                bookCover
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(book.title)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.adaptivePrimaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(book.author)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.adaptiveSecondaryText)
                        .lineLimit(1)
                    
                    if book.status == .reading {
                        progressBar
                    } else if book.status == .finished, let rating = book.rating {
                        ratingStars(rating)
                    } else {
                        statusBadge
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }
            .background(Color.adaptiveCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            .cardShadow()
        }
        .buttonStyle(ScaleButtonStyle())
        .onAppear {
            loadCoverImage()
        }
    }
    
    private func loadCoverImage() {
        if let filename = book.coverImageFilename {
            coverImage = photoManager.loadImage(filename: filename)
        }
    }
    
    private var bookCover: some View {
        ZStack(alignment: .bottomTrailing) {
            if let image = coverImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                book.coverColor,
                                book.coverColor.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 160)
                
                GeometryReader { geo in
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 80, height: 80)
                            .offset(x: -20, y: -20)
                        
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 60, height: 60)
                            .offset(x: geo.size.width - 40, y: geo.size.height - 30)
                        
                        VStack(spacing: 8) {
                            Text(book.title.initials)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Image(systemName: book.genre.icon)
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(height: 160)
            }
            
            HStack(spacing: 4) {
                Image(systemName: book.genre.icon)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color.black.opacity(0.4))
            .clipShape(Capsule())
            .padding(10)
        }
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: AppTheme.cornerRadius,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: AppTheme.cornerRadius
            )
        )
    }
    
    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(book.progressPercent)%")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primary)
                
                Spacer()
                
                Text("\(book.currentPage)/\(book.totalPages)")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.adaptiveTertiaryText)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.adaptiveDivider)
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(AppTheme.primaryGradient)
                        .frame(width: geo.size.width * book.progress, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(.top, 4)
    }
    
    private func ratingStars(_ rating: Int) -> some View {
        HStack(spacing: 3) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .font(.system(size: 11))
                    .foregroundColor(index <= rating ? .yellow : .adaptiveTertiaryText)
            }
        }
        .padding(.top, 4)
    }
    
    private var statusBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: book.status.icon)
                .font(.system(size: 10))
            Text(book.status.rawValue)
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundColor(book.status.color)
        .padding(.top, 4)
    }
}

struct BookListRowView: View {
    let book: Book
    var onTap: (() -> Void)? = nil
    
    @State private var coverImage: UIImage?
    private let photoManager = PhotoManager.shared
    
    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: 14) {
                miniCover
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.adaptivePrimaryText)
                        .lineLimit(1)
                    
                    Text(book.author)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.adaptiveSecondaryText)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: book.status.icon)
                                .font(.system(size: 10))
                            Text(book.status.rawValue)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(book.status.color)
                        
                        if book.status == .reading {
                            Text("•")
                                .foregroundColor(.adaptiveTertiaryText)
                            Text("\(book.progressPercent)%")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.primary)
                        }
                    }
                    .padding(.top, 2)
                }
                
                Spacer()
                
                if book.status == .reading {
                    ProgressRingView(progress: book.progress, size: 44, lineWidth: 4)
                }
            }
            .padding(12)
            .background(Color.adaptiveCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            .cardShadow()
        }
        .buttonStyle(ScaleButtonStyle())
        .onAppear {
            loadCoverImage()
        }
    }
    
    private func loadCoverImage() {
        if let filename = book.coverImageFilename {
            coverImage = photoManager.loadImage(filename: filename)
        }
    }
    
    private var miniCover: some View {
        Group {
            if let image = coverImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 80)
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
                        .frame(width: 56, height: 80)
                    
                    Text(book.title.initials)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
        }
    }
}

struct CurrentlyReadingCard: View {
    let book: Book
    var onTap: (() -> Void)? = nil
    var onUpdateProgress: (() -> Void)? = nil
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var coverImage: UIImage?
    private let photoManager = PhotoManager.shared
    
    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: 16) {
                bookCoverView
                    .shadow(color: book.coverColor.opacity(0.4), radius: 12, y: 6)
                
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(book.title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.adaptivePrimaryText)
                            .lineLimit(2)
                        
                        Text(book.author)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.adaptiveSecondaryText)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("\(book.progressPercent)% complete")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(AppTheme.primary)
                            
                            Spacer()
                            
                            Text("\(book.pagesRemaining) pages left")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.adaptiveTertiaryText)
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.adaptiveDivider)
                                    .frame(height: 8)
                                
                                Capsule()
                                    .fill(AppTheme.primaryGradient)
                                    .frame(width: geo.size.width * book.progress, height: 8)
                            }
                        }
                        .frame(height: 8)
                    }
                    
                    Button(action: { onUpdateProgress?() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 14))
                            Text("Update Progress")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(AppTheme.primaryGradient)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(16)
            .background(Color.adaptiveCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge))
            .cardShadow()
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            loadCoverImage()
        }
    }
    
    private func loadCoverImage() {
        if let filename = book.coverImageFilename {
            coverImage = photoManager.loadImage(filename: filename)
        }
    }
    
    private var bookCoverView: some View {
        Group {
            if let image = coverImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [book.coverColor, book.coverColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 140)
                    
                    VStack(spacing: 6) {
                        Text(book.title.initials)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Image(systemName: book.genre.icon)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
