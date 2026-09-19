//
//  GrimoireCustomFilterForm.swift
//  Sterium
//

import SwiftUI
import SwiftData

struct GrimoireCustomFilterForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var onSave: (GrimoireCustomFilter) -> Void = { _ in }

    @State private var name = ""
    @State private var selectedTypeNames: Set<String> = []

    private let typeOptions = GrimoireEntryType.allCases.map(\.displayName)

    private var canSave: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
        selectedTypeNames.isEmpty == false
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                    header

                    AsteriumTextField(
                        title: "Filter Name",
                        placeholder: "e.g. Divination Work...",
                        text: $name
                    )

                    AsteriumMultiSelectPickerField(
                        title: "Entry Types",
                        options: typeOptions,
                        selections: $selectedTypeNames
                    )

                    AsteriumPrimaryButton(title: "Save Filter", asset: "addwavy") {
                        save()
                    }
                    .disabled(canSave == false)
                    .opacity(canSave ? 1 : 0.55)
                }
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
            .background { AsteriumBackground() }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("CUSTOM FILTER")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(LGradients.header)

                Text("New Filter")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
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
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let rawValues = GrimoireEntryType.allCases
            .filter { selectedTypeNames.contains($0.displayName) }
            .map(\.rawValue)

        let filter = GrimoireCustomFilter(name: trimmed, typeRawValues: rawValues)
        modelContext.insert(filter)
        try? modelContext.save()
        onSave(filter)
        dismiss()
    }
}
