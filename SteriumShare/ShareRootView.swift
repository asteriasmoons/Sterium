//
//  ShareRootView.swift
//  SteriumShare
//

import SwiftUI
import SwiftData
import UIKit

@MainActor
@Observable
final class ShareModel {
    enum Phase {
        case loading
        case ready
        case noBoards
        case saving
        case saved
        case error(String)
    }

    var phase: Phase = .loading
    var boards: [VisionBoard] = []
    var selectedBoardID: UUID?
    var preview: UIImage?
    var carouselPreviews: [UIImage] = []

    private var loaded: LoadedShareImage?
    private var loadedCarousel: [LoadedShareImage] = []
    private var container: ModelContainer?
    private let providers: [NSItemProvider]

    init(providers: [NSItemProvider]) {
        self.providers = providers
    }

    func prepare() async {
        do {
            let container = try SteriumShared.makeModelContainer(cloudKitDatabase: .none)
            self.container = container

            let descriptor = FetchDescriptor<VisionBoard>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
            let boards = (try? container.mainContext.fetch(descriptor)) ?? []
            self.boards = boards

            let sourceURLString = await ShareImageLoader.loadSourceURL(from: providers)
            var loadedAsCarousel = false

            if let sourceURLString,
               let sourceURL = URL(string: sourceURLString),
               ShareImageLoader.isInstagramURL(sourceURL),
               let carousel = try? await InstagramCarouselResolver.resolve(
                   from: sourceURL,
                   sourceURLString: sourceURLString
               ),
               carousel.count > 1 {
                loadedCarousel = carousel
                carouselPreviews = carousel.compactMap { UIImage(data: $0.data) }
                loadedAsCarousel = true
            }

            if !loadedAsCarousel {
                let loaded = try await ShareImageLoader.loadImage(from: providers)
                self.loaded = loaded
                self.preview = UIImage(data: loaded.data)
            }

            if boards.isEmpty {
                phase = .noBoards
            } else {
                selectedBoardID = boards.first?.id
                phase = .ready
            }
        } catch {
            phase = .error((error as? LocalizedError)?.errorDescription ?? "Sterium couldn't prepare this image.")
        }
    }

    func add() {
        guard let container,
              let boardID = selectedBoardID,
              let board = boards.first(where: { $0.id == boardID })
        else {
            phase = .error("Choose a board to add this image to.")
            return
        }

        phase = .saving
        let context = container.mainContext

        if !loadedCarousel.isEmpty {
            for loaded in loadedCarousel {
                context.insert(makeVisionBoardImage(from: loaded, board: board))
            }
        } else if let loaded {
            context.insert(makeVisionBoardImage(from: loaded, board: board))
        } else {
            phase = .error("Sterium couldn't find an image to save.")
            return
        }

        board.updatedAt = Date()

        do {
            try context.save()
            phase = .saved
        } catch {
            phase = .error("Sterium couldn't save the image. Please try again.")
        }
    }

    private func makeVisionBoardImage(from loaded: LoadedShareImage, board: VisionBoard) -> VisionBoardImage {
        VisionBoardImage(
            imageData: loaded.data,
            width: loaded.width,
            height: loaded.height,
            originalFilename: loaded.filename,
            contentType: loaded.contentType,
            sourceApp: "Shared",
            sourceURLString: loaded.sourceURL,
            board: board
        )
    }
}

struct ShareRootView: View {
    @State private var model: ShareModel
    let onComplete: () -> Void
    let onCancel: () -> Void

    init(providers: [NSItemProvider], onComplete: @escaping () -> Void, onCancel: @escaping () -> Void) {
        _model = State(initialValue: ShareModel(providers: providers))
        self.onComplete = onComplete
        self.onCancel = onCancel
    }

    var body: some View {
        ZStack {
            LColors.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                titleBar

                switch model.phase {
                case .loading:
                    centered { ProgressView().tint(LColors.textPrimary) }
                case .noBoards:
                    noBoards
                case .saved:
                    centered {
                        Text("Added to Sterium")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)
                    }
                case .error(let message):
                    errorView(message)
                case .ready, .saving:
                    content
                }
            }
            .padding(18)
        }
        .task { await model.prepare() }
        .onChange(of: isSaved) { _, saved in
            if saved {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { onComplete() }
            }
        }
    }

    private var isSaved: Bool { if case .saved = model.phase { return true } else { return false } }
    private var isSaving: Bool { if case .saving = model.phase { return true } else { return false } }

    private var titleBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("STERIUM")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(LGradients.header)
                Text("Add to Vision Board")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
            }
            Spacer()
            Button(action: onCancel) {
                Text("Cancel")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(LGradients.header)
            }
            .buttonStyle(.plain)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 14) {
            if !model.carouselPreviews.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(model.carouselPreviews.enumerated()), id: \.offset) { _, preview in
                            Image(uiImage: preview)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 176, height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(LColors.glassBorder, lineWidth: 1)
                                }
                        }
                    }
                }
            } else if let preview = model.preview {
                Image(uiImage: preview)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(LColors.glassBorder, lineWidth: 1)
                    }
            }

            Text("CHOOSE A BOARD")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textSecondary)

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(model.boards) { board in
                        boardRow(board)
                    }
                }
            }
            .frame(maxHeight: 240)

            Button { model.add() } label: {
                Text(isSaving ? "Adding..." : "Add")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.bg)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(LGradients.header, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(isSaving || model.selectedBoardID == nil)
            .opacity(model.selectedBoardID == nil ? 0.55 : 1)
        }
    }

    private func boardRow(_ board: VisionBoard) -> some View {
        let isSelected = model.selectedBoardID == board.id
        return Button {
            model.selectedBoardID = board.id
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(board.name.isEmpty ? "Untitled Board" : board.name)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                    Text("\(board.imageCount) image\(board.imageCount == 1 ? "" : "s")")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)
                }
                Spacer()
                Circle()
                    .fill(isSelected ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.glassSurface))
                    .frame(width: 18, height: 18)
                    .overlay {
                        Circle().strokeBorder(isSelected ? Color.clear : LColors.glassBorder, lineWidth: 1)
                    }
            }
            .padding(14)
            .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(isSelected ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.glassBorder), lineWidth: isSelected ? 1.5 : 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var noBoards: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("No Vision Boards yet")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textPrimary)
            Text("Open Sterium and create a Vision Board first, then share images into it from here.")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(LColors.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
            glassButton("Close", action: onCancel)
        }
        .frame(maxWidth: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Text("Couldn't add image")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textPrimary)
            Text(message)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(LColors.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
            glassButton("Close", action: onCancel)
        }
        .frame(maxWidth: .infinity)
    }

    private func glassButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(LGradients.header)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(LColors.glassBorder, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    private func centered<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack { Spacer(); content(); Spacer() }.frame(maxWidth: .infinity)
    }
}
