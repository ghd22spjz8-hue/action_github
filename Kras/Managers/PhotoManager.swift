import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let edited = info[.editedImage] as? UIImage {
                parent.image = edited
            } else if let original = info[.originalImage] as? UIImage {
                parent.image = original
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }
            
            provider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
}

@MainActor
class PhotoManager {
    static let shared = PhotoManager()
    
    private let fileManager = FileManager.default
    private let imagesDirectory: URL
    
    private init() {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        imagesDirectory = documentsPath.appendingPathComponent("BookCovers", isDirectory: true)
        
        if !fileManager.fileExists(atPath: imagesDirectory.path) {
            try? fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        }
    }
    
    var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    func saveImage(_ image: UIImage, forBookId bookId: UUID) -> String? {
        let resized = resizeImage(image, maxSize: 800)
        
        guard let data = resized.jpegData(compressionQuality: 0.8) else { return nil }
        
        let filename = "\(bookId.uuidString).jpg"
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return filename
        } catch {
            return nil
        }
    }
    
    func loadImage(filename: String) -> UIImage? {
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
    
    func deleteImage(filename: String) {
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        try? fileManager.removeItem(at: fileURL)
    }
    
    private func resizeImage(_ image: UIImage, maxSize: CGFloat) -> UIImage {
        let size = image.size
        
        guard size.width > maxSize || size.height > maxSize else { return image }
        
        let ratio = min(maxSize / size.width, maxSize / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

struct ImageSourceSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?
    
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    
    private let photoManager = PhotoManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Add Cover Photo")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.adaptivePrimaryText)
                
                Spacer()
                
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.adaptiveSecondaryText)
                }
            }
            .padding()
            
            Divider()
            
            VStack(spacing: 12) {
                if photoManager.isCameraAvailable {
                    Button {
                        showCamera = true
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.15))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Take Photo")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.adaptivePrimaryText)
                                
                                Text("Use camera to capture book cover")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.adaptiveSecondaryText)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.adaptiveTertiaryText)
                        }
                        .padding(14)
                        .background(Color.adaptiveCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                
                Button {
                    showPhotoLibrary = true
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color.purple.opacity(0.15))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 20))
                                .foregroundColor(.purple)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Choose from Library")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.adaptivePrimaryText)
                            
                            Text("Select from your photo library")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.adaptiveSecondaryText)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.adaptiveTertiaryText)
                    }
                    .padding(14)
                    .background(Color.adaptiveCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
                if selectedImage != nil {
                    Button {
                        selectedImage = nil
                        isPresented = false
                        HapticManager.impact(.medium)
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.15))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.red)
                            }
                            
                            Text("Remove Photo")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                        .padding(14)
                        .background(Color.adaptiveCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding()
            
            Spacer()
        }
        .background(Color.adaptiveBackground)
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(image: $selectedImage, sourceType: .camera)
                .ignoresSafeArea()
                .onDisappear {
                    if selectedImage != nil {
                        isPresented = false
                    }
                }
        }
        .sheet(isPresented: $showPhotoLibrary) {
            PhotoPicker(image: $selectedImage)
                .onDisappear {
                    if selectedImage != nil {
                        isPresented = false
                    }
                }
        }
    }
}
