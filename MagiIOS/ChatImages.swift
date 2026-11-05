import SwiftUI
import UIKit
import ImageIO
import AVFoundation
import MagiCore

/// Decode to a bounded raster, apply orientation and omit location/camera metadata.
enum ImagePreparation {
    static func thumbnail(_ data: Data, maximum: Int = 2560) throws -> CGImage {
        guard !data.isEmpty, data.count <= 40 * 1024 * 1024 else { throw ClientError.responseTooLarge }
        guard let source = CGImageSourceCreateWithData(data as CFData, [kCGImageSourceShouldCache: false] as CFDictionary),
              let image = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: maximum,
                kCGImageSourceShouldCacheImmediately: true,
              ] as CFDictionary) else { throw ClientError.invalidResponse }
        return image
    }
    static func jpeg(_ data: Data) throws -> Data {
        let image = try thumbnail(data)
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(output, "public.jpeg" as CFString, 1, nil) else {
            throw ClientError.invalidResponse
        }
        CGImageDestinationAddImage(destination, image, [kCGImageDestinationLossyCompressionQuality: 0.88] as CFDictionary)
        guard CGImageDestinationFinalize(destination), output.length <= 8 * 1024 * 1024 else { throw ClientError.responseTooLarge }
        return output as Data
    }
}

struct CameraCapture: UIViewControllerRepresentable {
    let onImage: (Data) -> Void
    @Environment(\.dismiss) private var dismiss
    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = ["public.image"]
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}
    @MainActor final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraCapture
        init(parent: CameraCapture) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage, let data = image.jpegData(compressionQuality: 0.9) { parent.onImage(data) }
            parent.dismiss()
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { parent.dismiss() }
    }
}

struct ImagePreview: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    @State private var zoom = 1.0
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView([.horizontal, .vertical]) {
                    Image(uiImage: image).resizable().scaledToFit()
                        .frame(width: geometry.size.width * zoom, height: geometry.size.height * zoom)
                        .onTapGesture(count: 2) { withAnimation { zoom = zoom == 1 ? 2.5 : 1 } }
                        .accessibilityLabel(Text("attachment.image"))
                }
            }
            .background(.black)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("action.done") { dismiss() } } }
        }
    }
}

struct ChatImage: View {
    let sessionID: String
    let attachmentID: String
    @Environment(AppStore.self) private var store
    @State private var image: UIImage?
    @State private var failed = false
    @State private var previewing = false
    @State private var retry = 0
    var body: some View {
        Group {
            if let image {
                Button { previewing = true } label: {
                    Image(uiImage: image).resizable().scaledToFit().frame(maxWidth: 280, maxHeight: 300)
                }
                .accessibilityLabel(Text("attachment.preview"))
                .accessibilityIdentifier("chat.image")
                .fullScreenCover(isPresented: $previewing) { ImagePreview(image: image) }
            } else if failed {
                Button { retry += 1 } label: { Label("attachment.retry", systemImage: "arrow.clockwise") }
                    .frame(width: 200, height: 120)
            } else {
                ProgressView().frame(width: 200, height: 120).accessibilityLabel(Text("attachment.loading"))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .task(id: "\(sessionID)/\(attachmentID)/\(store.dataEpoch ?? "")/\(retry)") {
            image = nil; failed = false
            do {
                let data = try await store.image(sessionID: sessionID, attachmentID: attachmentID)
                let decoded = try await Task.detached { try ImagePreparation.thumbnail(data) }.value
                try Task.checkCancellation()
                image = UIImage(cgImage: decoded)
            } catch { if !Task.isCancelled { failed = true } }
        }
    }
}

struct DraftImage: View {
    let file: DraftAttachment
    let remove: () -> Void
    @State private var image: UIImage?
    @State private var previewing = false
    var body: some View {
        Button { previewing = true } label: {
            Group {
                if let image { Image(uiImage: image).resizable().scaledToFill() }
                else { Image(systemName: "photo") }
            }.frame(width: 72, height: 72).clipped().clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .accessibilityLabel(Text("attachment.preview"))
        .overlay(alignment: .topTrailing) {
            Button(action: remove) { Image(systemName: "xmark.circle.fill").symbolRenderingMode(.palette).foregroundStyle(.white, .black) }
                .padding(3).accessibilityLabel(Text("attachment.remove"))
        }
        .task(id: file.id) {
            if let decoded = try? await Task.detached(operation: { try ImagePreparation.thumbnail(file.data) }).value {
                image = UIImage(cgImage: decoded)
            }
        }
        .fullScreenCover(isPresented: $previewing) { if let image { ImagePreview(image: image) } }
    }
}
