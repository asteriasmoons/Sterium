//
//  ManifestationEntryDetail.swift
//  Sterium
//

import SwiftUI
import SwiftData

struct ManifestationEntryDetail: View {
    @Environment(\.modelContext) private var modelContext

    let entry: ManifestationEntry

    @State private var showingEdit = false
    @State private var showingEvidenceInput = false
    @State private var evidenceDraft = ""
    @State private var showingManifestedDatePicker = false

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Manifestation", title: entry.title, onEdit: { showingEdit = true }) {
            GrimoireDetailSection(title: "Date") {
                detailValue(entry.dateStarted.formatted(date: .long, time: .omitted))
            }

            gradientPillSection(title: "Type", items: displayedType)

            translucentPillSection(title: "Method", items: displayedMethods, emptyText: "No method")

            gradientPillSection(title: "Timeframe", items: displayedTimeframe)

            GrimoireDetailSection(title: "Desire") {
                detailValue(entry.desire)
            }

            GrimoireDetailSection(title: "Why It Matters") {
                detailValue(entry.whyItMatters)
            }

            stackedTileSection(title: "Intentions", items: intentions, emptyText: "No intentions")

            GrimoireDetailSection(title: "Desired Reality") {
                numberedRows(items: desiredReality, numberShape: .circle, emptyText: "No desired reality")
            }

            inspiredActionsSection

            stackedTileSection(title: "Obstacles", items: obstacles, emptyText: "No obstacles")

            evidenceSection

            statusSection

            GrimoireDetailSection(title: "Reflection") {
                detailValue(entry.reflection)
            }

            detailFooter
        }
        .asteriumAdaptivePresentation(isPresented: $showingEdit) {
            ManifestationEntryForm(existing: entry)
        }
    }

    private var displayedType: [String] {
        let custom = entry.customManifestationType.trimmingCharacters(in: .whitespacesAndNewlines)
        if entry.manifestationType == "Custom", !custom.isEmpty {
            return [custom]
        }

        let value = entry.manifestationType.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? [] : [value]
    }

    private var displayedMethods: [String] {
        let custom = entry.customManifestationMethod.trimmingCharacters(in: .whitespacesAndNewlines)
        return entry.manifestationMethods.map { method in
            method == "Custom" && !custom.isEmpty ? custom : method
        }
    }

    private var displayedTimeframe: [String] {
        let value = entry.timeframe.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return [] }

        if value == "Specific Date" {
            return [value, Self.shortDateFormatter.string(from: entry.specificTimeframeDate)]
        }

        return [value]
    }

    private var intentions: [String] {
        savedItems(entry.intentionItems, legacyValue: entry.intention)
    }

    private var desiredReality: [String] {
        savedItems(entry.desiredRealityItems, legacyValue: entry.visualization)
    }

    private var inspiredActions: [String] {
        savedItems(entry.inspiredActionItems, legacyValue: entry.inspiredActions)
    }

    private var obstacles: [String] {
        savedItems(entry.obstacleItems, legacyValue: entry.obstacles)
    }

    private var evidence: [String] {
        savedItems(entry.evidenceItems, legacyValue: entry.evidenceOfProgress)
    }

    private var inspiredActionsSection: some View {
        GrimoireDetailSection(title: "Inspired Actions") {
            if inspiredActions.isEmpty {
                Text("No inspired actions")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
            } else {
                ForEach(inspiredActions.indices, id: \.self) { index in
                    HStack(alignment: .center, spacing: 12) {
                        Circle()
                            .fill(LGradients.tag)
                            .frame(width: 11, height: 11)

                        Text(inspiredActions[index])
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }

    private var evidenceSection: some View {
        GrimoireDetailSection(title: "Evidence") {
            VStack(alignment: .leading, spacing: 14) {
                if !evidence.isEmpty {
                    numberedRows(items: evidence, numberShape: .circle, emptyText: "")
                }

                ManifestationDottedDivider()
                    .stroke(
                        Color.white.opacity(0.2),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [1, 6])
                    )
                    .frame(height: 2)

                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                        showingEvidenceInput.toggle()
                    }
                } label: {
                    HStack(spacing: 9) {
                        Text("Add Evidence")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.bg)

                        Spacer(minLength: 12)

                        Image("addwavy")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .foregroundStyle(LColors.bg)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(LGradients.header, in: Capsule())
                }
                .buttonStyle(.plain)

                if showingEvidenceInput {
                    HStack(spacing: 10) {
                        TextField("Evidence of progress...", text: $evidenceDraft)
                            .lineLimit(1)
                            .submitLabel(.done)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)
                            .padding(13)
                            .background(Color.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 13))
                            .overlay {
                                RoundedRectangle(cornerRadius: 13)
                                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                            }
                            .onSubmit(addEvidence)

                        Button(action: addEvidence) {
                            Image("addwavy")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 19, height: 19)
                                .foregroundStyle(LGradients.header)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 13))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 13)
                                        .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsteriumPickerField(
                title: "Status",
                options: ManifestationEntryForm.statusOptions,
                selection: statusBinding
            )

            if currentStatus == .manifested {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                        showingManifestedDatePicker.toggle()
                    }
                } label: {
                    Text(Self.shortDateFormatter.string(from: entry.manifestedDate))
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.12), in: Capsule())
                        .overlay {
                            Capsule()
                                .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)

                if showingManifestedDatePicker {
                    GlassCard(cornerRadius: LSpacing.cardRadius, padding: 12) {
                        DatePicker(
                            "",
                            selection: manifestedDateBinding,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .tint(LColors.accent)
                        .colorScheme(.dark)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                }

                AsteriumTextEditor(
                    title: "Outcome",
                    placeholder: "What really happened?",
                    text: outcomeBinding,
                    minHeight: 110
                )
            }
        }
    }

    private var detailFooter: some View {
        Group {
            VStack(alignment: .leading, spacing: 8) {
                AsteriumSectionHeader(title: "Importance")
                GrimoireImportanceDots(value: entry.importance, showsLabel: false)
            }

            VStack(alignment: .leading, spacing: 8) {
                AsteriumSectionHeader(title: "Tags")
                GrimoireDetailChips(label: "Tags", items: entry.tags, showsLabel: false)
            }

            if !entry.attachments.isEmpty {
                GrimoireDetailSection(title: "Attachments") {
                    GrimoireAttachmentGallery(attachments: entry.attachments)
                }
            }

            GrimoireRelatedEntriesList(entries: entry.relatedEntries)

            GrimoireDetailSection(title: "Additional Notes") {
                detailValue(entry.additionalNotes, emptyText: "No additional notes")
            }
        }
    }

    private var currentStatus: ManifestationStatus {
        ManifestationStatus(rawValue: entry.manifestationStatusRawValue) ?? .inProgress
    }

    private var currentStatusDisplay: String {
        currentStatus == .notManifested ? "Released" : currentStatus.displayName
    }

    private var statusBinding: Binding<String> {
        Binding(
            get: { currentStatusDisplay },
            set: { value in
                entry.manifestationStatusRawValue = ManifestationEntryForm.status(from: value).rawValue
                persistEntryChange()
            }
        )
    }

    private var manifestedDateBinding: Binding<Date> {
        Binding(
            get: { entry.manifestedDate },
            set: { value in
                entry.manifestedDate = value
                persistEntryChange()
            }
        )
    }

    private var outcomeBinding: Binding<String> {
        Binding(
            get: { entry.outcome },
            set: { value in
                entry.outcome = value
                entry.updatedAt = .now
            }
        )
    }

    private func gradientPillSection(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            AsteriumSectionHeader(title: title)
            GrimoireDetailChips(label: title, items: items, showsLabel: false)
        }
    }

    private func translucentPillSection(title: String, items: [String], emptyText: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            AsteriumSectionHeader(title: title)

            FlowLayout(spacing: 8) {
                if items.isEmpty {
                    translucentPill(emptyText, isEmpty: true)
                } else {
                    ForEach(items.indices, id: \.self) { index in
                        translucentPill(items[index])
                    }
                }
            }
        }
    }

    private func translucentPill(_ value: String, isEmpty: Bool = false) -> some View {
        Text(value)
            .font(.system(size: 13, weight: .black, design: .rounded))
            .foregroundStyle(isEmpty ? LColors.textSecondary : LColors.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.12), in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
            }
    }

    private func stackedTileSection(title: String, items: [String], emptyText: String) -> some View {
        GrimoireDetailSection(title: title) {
            VStack(alignment: .leading, spacing: 10) {
                if items.isEmpty {
                    translucentTile(emptyText, isEmpty: true)
                } else {
                    ForEach(items.indices, id: \.self) { index in
                        translucentTile(items[index])
                    }
                }
            }
        }
    }

    private func translucentTile(_ value: String, isEmpty: Bool = false) -> some View {
        Text(value)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(isEmpty ? LColors.textSecondary : LColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
            }
    }

    private enum NumberShape: Equatable {
        case circle
        case rounded
    }

    private func numberedRows(items: [String], numberShape: NumberShape, emptyText: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if items.isEmpty {
                if !emptyText.isEmpty {
                    detailValue(emptyText, emptyText: emptyText)
                }
            } else {
                ForEach(items.indices, id: \.self) { index in
                    HStack(alignment: .center, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.bg)
                            .frame(width: 28, height: 28)
                            .background {
                                if numberShape == .circle {
                                    Circle().fill(LGradients.tag)
                                } else {
                                    RoundedRectangle(cornerRadius: 9).fill(LGradients.tag)
                                }
                            }

                        Text(items[index])
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }

    private func detailValue(_ value: String, emptyText: String = "No details") -> some View {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return Text(trimmed.isEmpty ? emptyText : trimmed)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(trimmed.isEmpty ? LColors.textSecondary : LColors.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func savedItems(_ items: [String], legacyValue: String) -> [String] {
        if !items.isEmpty {
            return items
        }

        let trimmed = legacyValue.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? [] : [trimmed]
    }

    private func addEvidence() {
        let value = evidenceDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }

        var updatedEvidence = evidence
        updatedEvidence.append(value)
        entry.evidenceItems = updatedEvidence
        entry.evidenceOfProgress = updatedEvidence.joined(separator: "\n")
        evidenceDraft = ""
        showingEvidenceInput = false
        persistEntryChange()
    }

    private func persistEntryChange() {
        entry.updatedAt = .now
        try? modelContext.save()
    }

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
}

private struct ManifestationDottedDivider: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
