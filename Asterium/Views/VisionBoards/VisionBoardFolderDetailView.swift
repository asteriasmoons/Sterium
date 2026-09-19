//
//  VisionBoardFolderDetailView.swift
//  Sterium
//
//  A folder inside a Vision Board. Behaves like VisionBoardDetailView but
//  scoped to a single folder's images. Reuses the existing masonry, image
//  loader, and image viewer.
//

import SwiftUI
import SwiftData
import PhotosUI

struct VisionBoardFolderDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let folder: VisionBoardFolder

    @Query private var images: [VisionBoardImage]

    @State private var showingEdit = false
    @State private var viewerImage: VisionBoardImage?
    @State private var photoItem: PhotosPickerItem?
    @State private var isImporting = false

    init(folder: VisionBoardFolder) {
        self.folder = folder
        let folderID = folder.id
        _images = Query(
            filter: #Predicate<VisionBoardImage> { $0.folder?.id == folderID },
            sort: \VisionBoardImage.importedAt,
            order: .reverse
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                header

                Text("\(images.count) image\(images.count == 1 ? "" : "s")")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(LGradients.header)

                if images.isEmpty {
                    emptyState
                } else {
                    VisionBoardMasonry(images: images) { image in
                        viewerImage = image
                    }
                }
            }
            .padding(.horizontal, LSpacing.pageHorizontal)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background { AsteriumBackground() }
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            Task { await importPhoto(item) }
        }
        .asteriumAdaptivePresentation(isPresented: $showingEdit) {
            VisionBoardFolderCreateEditView(board: folder.board ?? VisionBoard(name: ""), folder: folder) {
                dismiss()
            }
        }
        .asteriumAdaptivePresentation(
            isPresented: Binding(
                get: { viewerImage != nil },
                set: { if $0 == false { viewerImage = nil } }
            )
        ) {
            if let viewerImage {
                VisionBoardImageViewer(image: viewerImage)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("FOLDER")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(LGradients.header)

                Text(folder.name.isEmpty ? "Untitled Folder" : folder.name)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            HStack(spacing: 10) {
                PhotosPicker(selection: $photoItem, matching: .images) {
                    circleIcon(isImporting ? "hourglassfill" : "addwavy")
                }
                .disabled(isImporting)

                Button { showingEdit = true } label: { circleIcon("pencil") }
                    .buttonStyle(.plain)

                Button { dismiss() } label: { circleIcon("xmarkwavy") }
                    .buttonStyle(.plain)
            }
        }
        .padding(.top, 16)
    }

    private func circleIcon(_ asset: String) -> some View {
        Image(asset)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
            .foregroundStyle(LGradients.header)
            .frame(width: 42, height: 42)
            .background(LColors.glassSurface, in: Circle())
    }

    private var emptyState: some View {
        GlassCard {
            VStack(spacing: 12) {
                Image("openedfolder")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(LGradients.header)

                Text("No images in this folder")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)

                Text("Add an image from your library, or move images here from the board.")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                PhotosPicker(selection: $photoItem, matching: .images) {
                    HStack(spacing: 10) {
                        Image("addwavy")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                        Text("Add Image")
                            .font(.system(size: 15, weight: .black, design: .rounded))
                    }
                    .foregroundStyle(LColors.bg)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(LGradients.header, in: RoundedRectangle(cornerRadius: LSpacing.buttonRadius))
                }
                .disabled(isImporting)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }

    private func importPhoto(_ item: PhotosPickerItem) async {
        isImporting = true
        defer { isImporting = false; photoItem = nil }

        guard let data = try? await item.loadTransferable(type: Data.self), data.isEmpty == false else { return }

        let size = VisionBoardStore.pixelSize(of: data) ?? CGSize(width: 1, height: 1)
        let contentType = VisionBoardStore.contentType(of: data)

        let image = VisionBoardImage(
            imageData: data,
            width: Double(size.width),
            height: Double(size.height),
            contentType: contentType,
            sourceApp: "Photos",
            board: folder.board,
            folder: folder
        )
        modelContext.insert(image)
        folder.updatedAt = Date()
        folder.board?.updatedAt = Date()
        try? modelContext.save()
    }
}
