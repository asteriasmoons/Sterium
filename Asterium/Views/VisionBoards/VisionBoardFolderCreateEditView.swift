//
//  VisionBoardFolderCreateEditView.swift
//  Sterium
//
//  Create or rename a folder inside a Vision Board. Mirrors
//  VisionBoardCreateEditView's structure and Sterium form components.
//

import SwiftUI
import SwiftData

struct VisionBoardFolderCreateEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let board: VisionBoard
    private let folder: VisionBoardFolder?
    private let onDelete: (() -> Void)?

    @State private var name: String
    @State private var showingDelete = false

    init(board: VisionBoard, folder: VisionBoardFolder? = nil, onDelete: (() -> Void)? = nil) {
        self.board = board
        self.folder = folder
        self.onDelete = onDelete
        _name = State(initialValue: folder?.name ?? "")
    }

    private var isEditing: Bool { folder != nil }

    private var canSave: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                    header

                    AsteriumTextField(
                        title: "Folder Name",
                        placeholder: "e.g. Brand Identity...",
                        text: $name
                    )

                    AsteriumPrimaryButton(title: isEditing ? "Save Changes" : "Create Folder", asset: "openedfolder") {
                        save()
                    }
                    .disabled(canSave == false)
                    .opacity(canSave ? 1 : 0.55)

                    if isEditing {
                        Button { showingDelete = true } label: {
                            HStack(spacing: 10) {
                                Image("trash")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                                Text("Delete Folder")
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

                        Text("Deleting a folder keeps its images — they move back to the board.")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(LColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
            .background { AsteriumBackground() }
            .toolbar(.hidden, for: .navigationBar)
            .confirmationDialog("Delete this folder? Its images move back to the board.", isPresented: $showingDelete, titleVisibility: .visible) {
                Button("Delete Folder", role: .destructive) { deleteFolder() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(isEditing ? "EDIT FOLDER" : "NEW FOLDER")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(LGradients.header)

                Text(isEditing ? "Edit Folder" : "Folder")
                    .font(.system(size: 30, weight: .black, design: .rounded))
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

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if let folder {
            folder.name = trimmedName
            folder.updatedAt = Date()
        } else {
            let newFolder = VisionBoardFolder(name: trimmedName, board: board)
            modelContext.insert(newFolder)
        }
        board.updatedAt = Date()

        try? modelContext.save()
        dismiss()
    }

    private func deleteFolder() {
        guard let folder else { return }
        // Return the folder's images to the board root rather than destroying
        // them, then delete the folder.
        for image in folder.images ?? [] {
            image.folder = nil
        }
        modelContext.delete(folder)
        board.updatedAt = Date()
        try? modelContext.save()
        onDelete?()
        dismiss()
    }
}
