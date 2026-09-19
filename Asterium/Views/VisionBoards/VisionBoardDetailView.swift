//
//  VisionBoardDetailView.swift
//  Sterium
//

import SwiftUI
import SwiftData
import PhotosUI

struct VisionBoardDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let board: VisionBoard

    // Root-level images: on this board and NOT inside any folder. Auto-refreshes
    // as the store changes (in-app add, or an image shared in via the extension).
    @Query private var rootImages: [VisionBoardImage]

    // Folders that live inside this board.
    @Query private var folders: [VisionBoardFolder]

    @State private var showingEdit = false
    @State private var showingCreateFolder = false
    @State private var viewerImage: VisionBoardImage?
    @State private var photoItem: PhotosPickerItem?
    @State private var isImporting = false

    init(board: VisionBoard) {
        self.board = board
        let boardID = board.id
        _rootImages = Query(
            filter: #Predicate<VisionBoardImage> { $0.board?.id == boardID && $0.folder == nil },
            sort: \VisionBoardImage.importedAt,
            order: .reverse
        )
        _folders = Query(
            filter: #Predicate<VisionBoardFolder> { $0.board?.id == boardID },
            sort: \VisionBoardFolder.updatedAt,
            order: .reverse
        )
    }

    private let folderColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                header

                if board.boardDescription.isEmpty == false {
                    Text(board.boardDescription)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text("\(board.imageCount) image\(board.imageCount == 1 ? "" : "s")")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(LGradients.header)

                newFolderButton

                if folders.isEmpty == false {
                    LazyVGrid(columns: folderColumns, spacing: 12) {
                        ForEach(folders) { folder in
                            NavigationLink {
                                VisionBoardFolderDetailView(folder: folder)
                            } label: {
                                VisionBoardFolderCard(folder: folder)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if rootImages.isEmpty {
                    if folders.isEmpty {
                        emptyState
                    }
                } else {
                    VisionBoardMasonry(images: rootImages) { image in
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
            VisionBoardCreateEditView(board: board) {
                dismiss()
            }
        }
        .asteriumAdaptivePresentation(isPresented: $showingCreateFolder) {
            VisionBoardFolderCreateEditView(board: board)
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
                Text("VISION BOARD")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(LGradients.header)

                Text(board.name.isEmpty ? "Untitled Board" : board.name)
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

    private var newFolderButton: some View {
        Button { showingCreateFolder = true } label: {
            HStack(spacing: 10) {
                Image("openedfolder")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                Text("New Folder")
                    .font(.system(size: 15, weight: .black, design: .rounded))
            }
            .foregroundStyle(LGradients.header)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: LSpacing.buttonRadius))
            .overlay {
                RoundedRectangle(cornerRadius: LSpacing.buttonRadius)
                    .strokeBorder(LColors.glassBorder, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
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
                Image("artboard")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(LGradients.header)

                Text("No images yet")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)

                Text("Add an image from your library, or share one into Sterium from another app through the iOS Share Sheet.")
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
            board: board
        )
        modelContext.insert(image)
        board.updatedAt = Date()
        try? modelContext.save()
    }
}

// A folder card that mirrors the Vision Board card aesthetic on the main screen.
private struct VisionBoardFolderCard: View {
    let folder: VisionBoardFolder

    var body: some View {
        GlassCard(cornerRadius: 18, padding: 12) {
            VStack(alignment: .leading, spacing: 10) {
                VisionBoardCover(images: Array(folder.sortedImages.prefix(4)))
                    .frame(height: 150)

                Text(folder.name.isEmpty ? "Untitled Folder" : folder.name)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .lineLimit(1)

                Text("\(folder.imageCount) image\(folder.imageCount == 1 ? "" : "s")")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(LGradients.header)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
