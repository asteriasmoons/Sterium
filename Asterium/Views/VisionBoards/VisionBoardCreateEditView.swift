//
//  VisionBoardCreateEditView.swift
//  Sterium
//

import SwiftUI
import SwiftData

struct VisionBoardCreateEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let board: VisionBoard?
    private let onDelete: (() -> Void)?

    @State private var name: String
    @State private var boardDescription: String
    @State private var showingDelete = false

    init(board: VisionBoard? = nil, onDelete: (() -> Void)? = nil) {
        self.board = board
        self.onDelete = onDelete
        _name = State(initialValue: board?.name ?? "")
        _boardDescription = State(initialValue: board?.boardDescription ?? "")
    }

    private var isEditing: Bool { board != nil }

    private var canSave: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                    header

                    AsteriumTextField(
                        title: "Board Name",
                        placeholder: "e.g. Autumn Magic...",
                        text: $name
                    )

                    AsteriumTextEditor(
                        title: "Description",
                        placeholder: "What is this collection about? (optional)",
                        text: $boardDescription,
                        minHeight: 110
                    )

                    AsteriumPrimaryButton(title: isEditing ? "Save Changes" : "Create Board", asset: "addwavy") {
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
                                Text("Delete Board")
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
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
            .background { AsteriumBackground() }
            .toolbar(.hidden, for: .navigationBar)
            .confirmationDialog("Delete this board and all its images?", isPresented: $showingDelete, titleVisibility: .visible) {
                Button("Delete Board", role: .destructive) { deleteBoard() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func deleteBoard() {
        guard let board else { return }
        modelContext.delete(board)
        try? modelContext.save()
        onDelete?()
        dismiss()
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(isEditing ? "EDIT BOARD" : "NEW BOARD")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(LGradients.header)

                Text(isEditing ? "Edit Board" : "Vision Board")
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
        let trimmedDescription = boardDescription.trimmingCharacters(in: .whitespacesAndNewlines)

        if let board {
            board.name = trimmedName
            board.boardDescription = trimmedDescription
            board.updatedAt = Date()
        } else {
            let newBoard = VisionBoard(name: trimmedName, boardDescription: trimmedDescription)
            modelContext.insert(newBoard)
        }

        try? modelContext.save()
        dismiss()
    }
}
