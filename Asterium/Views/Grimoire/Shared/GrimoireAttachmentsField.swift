
//
//  GrimoireAttachmentsField.swift
//  Sterium
//

import SwiftUI
import PhotosUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

struct GrimoireAttachmentsField: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var attachments: [GrimoireAttachment]
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ATTACHMENTS")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textSecondary)

            if !attachments.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(attachments, id: \.id) { attachment in
                            attachmentThumbnail(attachment)
                        }
                    }
                }
            }

            PhotosPicker(
                selection: $selectedItem,
                matching: .images
            ) {
                HStack(spacing: 10) {
                    Image("grimoire")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)

                    Text("Add Attachment")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundStyle(LColors.textPrimary)
                .padding(14)
                .frame(maxWidth: .infinity)
                .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: LSpacing.inputRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: LSpacing.inputRadius)
                        .strokeBorder(LColors.glassBorder, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
            .onChange(of: selectedItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    await loadPhoto(from: newItem)
                    selectedItem = nil
                }
            }
        }
    }

    @ViewBuilder
    private func attachmentThumbnail(_ attachment: GrimoireAttachment) -> some View {
        ZStack(alignment: .topTrailing) {
            GrimoireAttachmentThumbnail(attachment: attachment, size: 72, showsDisplayName: true)

            Button {
                attachments.removeAll { $0.id == attachment.id }
                modelContext.delete(attachment)
            } label: {
                ZStack {
                    Circle()
                        .fill(LColors.glassSurface2)
                        .frame(width: 22, height: 22)

                    Text("\u{2715}")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                }
            }
            .buttonStyle(.plain)
            .offset(x: 6, y: -6)
        }
    }

    private func loadPhoto(from item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        #if canImport(UIKit)
        guard let image = UIImage(data: data), let imageData = image.jpegData(compressionQuality: 0.9) else { return }
        #else
        let imageData = data
        #endif

        let fileName = "photo_\(UUID().uuidString.prefix(8)).jpg"
        let relativePath = "attachments/\(fileName)"

        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        let attachmentsDir = documentsURL.appendingPathComponent("attachments", isDirectory: true)
        let fileURL = documentsURL.appendingPathComponent(relativePath)

        do {
            try FileManager.default.createDirectory(at: attachmentsDir, withIntermediateDirectories: true)
            try imageData.write(to: fileURL, options: .atomic)
        } catch {
            return
        }

        let attachment = GrimoireAttachment(
            displayName: fileName,
            relativePath: relativePath,
            kind: "photo"
        )
        modelContext.insert(attachment)
        attachments.append(attachment)
    }
}

struct GrimoireAttachmentThumbnail: View {
    let attachment: GrimoireAttachment
    var size: CGFloat = 88
    var showsDisplayName = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: LSpacing.inputRadius, style: .continuous)
                .fill(LColors.glassSurface2)

            thumbnailContent
        }
        .frame(width: size, height: size)
        .overlay {
            RoundedRectangle(cornerRadius: LSpacing.inputRadius, style: .continuous)
                .strokeBorder(LColors.glassBorder, lineWidth: 1)
        }
    }

    @ViewBuilder
    private var thumbnailContent: some View {
        #if canImport(UIKit)
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: LSpacing.inputRadius, style: .continuous))
        } else {
            placeholderContent
        }
        #else
        placeholderContent
        #endif
    }

    private var placeholderContent: some View {
        VStack(spacing: 4) {
            Image("grimoire")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(LColors.textSecondary)

            if showsDisplayName {
                Text(attachment.displayName)
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .lineLimit(1)
            }
        }
        .padding(6)
    }

    #if canImport(UIKit)
    private var image: UIImage? {
        guard let fileURL else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }
    #endif

    private var fileURL: URL? {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(attachment.relativePath)
    }
}

struct GrimoireAttachmentGallery: View {
    let attachments: [GrimoireAttachment]

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(attachments, id: \.id) { attachment in
                        GrimoireAttachmentDetailPreview(
                            attachment: attachment,
                            maxWidth: proxy.size.width
                        )
                    }
                }
                .frame(minWidth: proxy.size.width, alignment: .center)
            }
        }
        .frame(height: 190)
    }
}

private struct GrimoireAttachmentDetailPreview: View {
    let attachment: GrimoireAttachment
    let maxWidth: CGFloat

    var body: some View {
        #if canImport(UIKit)
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: previewSize.width, height: previewSize.height)
                .clipShape(RoundedRectangle(cornerRadius: LSpacing.inputRadius, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: LSpacing.inputRadius, style: .continuous)
                        .strokeBorder(LColors.glassBorder, lineWidth: 1)
                }
        } else {
            GrimoireAttachmentThumbnail(attachment: attachment, size: 180, showsDisplayName: true)
        }
        #else
        GrimoireAttachmentThumbnail(attachment: attachment, size: 180, showsDisplayName: true)
        #endif
    }

    #if canImport(UIKit)
    private var image: UIImage? {
        guard let fileURL else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }

    private var previewSize: CGSize {
        guard let image else {
            return CGSize(width: 180, height: 180)
        }

        let availableWidth = max(maxWidth, 1)
        let width = min(image.size.width, availableWidth)
        let ratio = image.size.height / max(image.size.width, 1)
        let height = min(width * ratio, 190)
        return CGSize(width: width, height: height)
    }
    #endif

    private var fileURL: URL? {
        if let url = URL(string: attachment.relativePath), url.isFileURL {
            return url
        }

        if attachment.relativePath.hasPrefix("/") {
            return URL(fileURLWithPath: attachment.relativePath)
        }

        return FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(attachment.relativePath)
    }
}
