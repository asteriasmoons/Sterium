//
//  VisionBoardImageViewer.swift
//  Sterium
//

import SwiftUI
import SwiftData
import Photos

struct VisionBoardImageViewer: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let image: VisionBoardImage

    @State private var fullImage: UIImage?
    @State private var showingCopy = false
    @State private var showingDelete = false
    @State private var isSavingToPhotos = false
    @State private var showSavedToPhotos = false
    @State private var saveErrorMessage: String?
    @State private var movePrimary = ""
    @State private var moveBoard = ""

    @Query(sort: \VisionBoard.updatedAt, order: .reverse) private var allBoards: [VisionBoard]

    private let boardRootLabel = "Board Root"
    private let boardLabel = "Board"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                    header

                    imageContent

                    metadata

                    actions
                }
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
            .background { AsteriumBackground() }
            .toolbar(.hidden, for: .navigationBar)
            .task(id: image.id) {
                fullImage = await VisionBoardImageLoader.shared.fullImage(data: image.imageData)
            }
            .asteriumAdaptivePresentation(isPresented: $showingCopy) {
                VisionBoardChooser(title: "Copy to Board", excludeBoardID: nil) { target in
                    copy(to: target)
                }
            }
            .confirmationDialog("Delete this image?", isPresented: $showingDelete, titleVisibility: .visible) {
                Button("Delete Image", role: .destructive) { deleteImage() }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Saved to Photos", isPresented: $showSavedToPhotos) {
                Button("OK", role: .cancel) {}
            }
            .alert(
                "Couldn't Save",
                isPresented: Binding(
                    get: { saveErrorMessage != nil },
                    set: { if $0 == false { saveErrorMessage = nil } }
                ),
                presenting: saveErrorMessage
            ) { _ in
                Button("OK", role: .cancel) {}
            } message: { message in
                Text(message)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("IMAGE")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(LGradients.header)

                Text(image.board?.name ?? "Vision Board")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Button { dismiss() } label: {
                Image("xmarkwavy")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(LGradients.header)
                    .frame(width: 42, height: 42)
                    .background(LColors.glassSurface, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 16)
    }

    @ViewBuilder
    private var imageContent: some View {
        ZStack {
            if let fullImage {
                Image(uiImage: fullImage)
                    .resizable()
                    .scaledToFit()
            } else {
                LColors.glassSurface
                    .frame(height: 280)
                ProgressView().tint(LColors.textPrimary)
            }
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: LSpacing.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: LSpacing.cardRadius, style: .continuous)
                .strokeBorder(LColors.glassBorder, lineWidth: 1)
        }
    }

    @ViewBuilder
    private var metadata: some View {
        let rows = metadataRows
        if rows.isEmpty == false {
            GlassCard {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(rows, id: \.0) { row in
                        VStack(alignment: .leading, spacing: 3) {
                            Text(row.0)
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundStyle(LColors.textSecondary)
                            Text(row.1)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(LColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var metadataRows: [(String, String)] {
        var rows: [(String, String)] = []
        if let source = image.sourceApp, source.isEmpty == false { rows.append(("SOURCE", source)) }
        if let url = image.sourceURLString, url.isEmpty == false { rows.append(("ORIGINAL LINK", url)) }
        if image.width > 0, image.height > 0 {
            rows.append(("DIMENSIONS", "\(Int(image.width)) × \(Int(image.height))"))
        }
        rows.append(("IMPORTED", image.importedAt.formatted(date: .abbreviated, time: .shortened)))
        return rows
    }

    private var actions: some View {
        VStack(spacing: 12) {
            moveSection
            AsteriumPrimaryButton(title: "Copy to Board", asset: "copy") { showingCopy = true }
            AsteriumPrimaryButton(title: isSavingToPhotos ? "Saving..." : "Save to Photos", asset: "download") { saveToPhotos() }
            Button { showingDelete = true } label: {
                HStack(spacing: 10) {
                    Image("trash")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text("Delete from Board")
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
    }

    private func saveToPhotos() {
        guard isSavingToPhotos == false else { return }
        isSavingToPhotos = true
        let data = image.imageData

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async {
                    isSavingToPhotos = false
                    saveErrorMessage = "Sterium needs permission to add photos. Enable Photos access for Sterium in Settings."
                }
                return
            }

            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .photo, data: data, options: nil)
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    isSavingToPhotos = false
                    if success {
                        showSavedToPhotos = true
                    } else {
                        saveErrorMessage = error?.localizedDescription ?? "The image couldn't be saved to your photo library."
                    }
                }
            }
        }
    }

    // MARK: - Move (custom single-select dropdowns)

    private var moveSection: some View {
        VStack(spacing: 12) {
            AsteriumPickerField(
                title: "MOVE TO",
                options: firstMoveOptions,
                selection: $movePrimary,
                leadingAsset: "rightwavy"
            )

            if movePrimary == boardLabel {
                AsteriumPickerField(
                    title: "BOARD",
                    options: otherBoardOptions,
                    selection: $moveBoard,
                    leadingAsset: "artboard"
                )
            }
        }
        .onChange(of: movePrimary) { _, value in handlePrimarySelection(value) }
        .onChange(of: moveBoard) { _, value in handleBoardSelection(value) }
    }

    private var currentFolders: [VisionBoardFolder] {
        (image.board?.folders ?? [])
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func folderLabel(_ folder: VisionBoardFolder) -> String {
        folder.name.isEmpty ? "Untitled Folder" : folder.name
    }

    private func boardName(_ board: VisionBoard) -> String {
        board.name.isEmpty ? "Untitled Board" : board.name
    }

    private var firstMoveOptions: [String] {
        let currentFolderID = image.folder?.id
        var options = currentFolders
            .filter { $0.id != currentFolderID }
            .map { folderLabel($0) }
        if image.folder != nil {
            options.append(boardRootLabel)
        }
        options.append(boardLabel)
        return options
    }

    private var otherBoards: [VisionBoard] {
        allBoards.filter { $0.id != image.board?.id }
    }

    private var otherBoardOptions: [String] {
        otherBoards.map { boardName($0) }
    }

    private func handlePrimarySelection(_ value: String) {
        guard value.isEmpty == false else { return }

        if value == boardLabel {
            moveBoard = ""     // reveal the second dropdown; await a board choice
            return
        }
        if value == boardRootLabel {
            moveImageToRoot()
            return
        }
        if let folder = currentFolders.first(where: { folderLabel($0) == value }) {
            moveImage(to: folder)
        }
    }

    private func handleBoardSelection(_ value: String) {
        guard value.isEmpty == false else { return }
        if let target = otherBoards.first(where: { boardName($0) == value }) {
            moveImage(toBoardRoot: target)
        }
    }

    private func moveImage(to folder: VisionBoardFolder) {
        image.folder = folder
        // image.board intentionally stays the folder's parent board.
        folder.updatedAt = Date()
        image.board?.updatedAt = Date()
        try? modelContext.save()
        dismiss()
    }

    private func moveImageToRoot() {
        image.folder = nil
        image.board?.updatedAt = Date()
        try? modelContext.save()
        dismiss()
    }

    private func moveImage(toBoardRoot target: VisionBoard) {
        let previousBoard = image.board
        image.folder = nil
        image.board = target
        target.updatedAt = Date()
        previousBoard?.updatedAt = Date()
        try? modelContext.save()
        dismiss()
    }

    private func copy(to board: VisionBoard) {
        let duplicate = VisionBoardImage(
            imageData: image.imageData,
            width: image.width,
            height: image.height,
            originalFilename: image.originalFilename,
            contentType: image.contentType,
            sourceApp: image.sourceApp,
            sourceURLString: image.sourceURLString,
            board: board
        )
        modelContext.insert(duplicate)
        board.updatedAt = Date()
        try? modelContext.save()
        dismiss()
    }

    private func deleteImage() {
        let board = image.board
        modelContext.delete(image)
        board?.updatedAt = Date()
        try? modelContext.save()
        dismiss()
    }
}

private struct VisionBoardChooser: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let excludeBoardID: UUID?
    let onPick: (VisionBoard) -> Void

    @Query(sort: \VisionBoard.updatedAt, order: .reverse)
    private var boards: [VisionBoard]

    private var options: [VisionBoard] {
        boards.filter { $0.id != excludeBoardID }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(title)
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)
                        Spacer()
                        Button { dismiss() } label: {
                            Image("xmarkwavy")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .foregroundStyle(LGradients.header)
                                .frame(width: 42, height: 42)
                                .background(LColors.glassSurface, in: Circle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 16)

                    if options.isEmpty {
                        Text("No other boards available. Create another board first.")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(LColors.textSecondary)
                            .padding(.top, 20)
                    } else {
                        ForEach(options) { board in
                            Button {
                                onPick(board)
                                dismiss()
                            } label: {
                                GlassCard(cornerRadius: 16, padding: 14) {
                                    HStack(spacing: 12) {
                                        Image("artboard")
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 22, height: 22)
                                            .foregroundStyle(LGradients.header)
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(board.name.isEmpty ? "Untitled Board" : board.name)
                                                .font(.system(size: 16, weight: .black, design: .rounded))
                                                .foregroundStyle(LColors.textPrimary)
                                            Text("\(board.imageCount) image\(board.imageCount == 1 ? "" : "s")")
                                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                                .foregroundStyle(LColors.textSecondary)
                                        }
                                        Spacer()
                                        Image("rightwavy")
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16, height: 16)
                                            .foregroundStyle(LGradients.header)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
            .background { AsteriumBackground() }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}
