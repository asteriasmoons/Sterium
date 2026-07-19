
//
//  GrimoireAttachmentsField.swift
//  Asterium
//

import SwiftUI
import PhotosUI

struct GrimoireAttachmentsField: View {
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
            RoundedRectangle(cornerRadius: LSpacing.inputRadius, style: .continuous)
                .fill(LColors.glassSurface2)
                .frame(width: 72, height: 72)
                .overlay {
                    VStack(spacing: 4) {
                        Image("grimoire")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(LColors.textSecondary)

                        Text(attachment.displayName)
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(LColors.textSecondary)
                            .lineLimit(1)
                    }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: LSpacing.inputRadius, style: .continuous)
                        .strokeBorder(LColors.glassBorder, lineWidth: 1)
                }

            Button {
                attachments.removeAll { $0.id == attachment.id }
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
        let fileName = "photo_\(UUID().uuidString.prefix(8)).jpg"
        let relativePath = "attachments/\(fileName)"

        // Save to app documents
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let attachmentsDir = documentsURL.appendingPathComponent("attachments", isDirectory: true)
            try? FileManager.default.createDirectory(at: attachmentsDir, withIntermediateDirectories: true)
            let fileURL = documentsURL.appendingPathComponent(relativePath)
            try? data.write(to: fileURL)
        }

        let attachment = GrimoireAttachment(
            displayName: fileName,
            relativePath: relativePath,
            kind: "photo"
        )
        attachments.append(attachment)
    }
}
