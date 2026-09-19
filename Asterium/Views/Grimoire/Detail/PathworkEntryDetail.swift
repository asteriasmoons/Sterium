//
//  PathworkEntryDetail.swift
//  Sterium
//

import SwiftUI
import SafariServices

struct PathworkEntryDetail: View {
    let entry: PathworkEntry
    @State private var showingEdit = false
    @State private var browserDestination: PathworkBrowserDestination?

    private var practiceItems: [String] {
        entry.currentPractices
            .split(separator: "|")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private var goals: [String] { listItems(entry.goals) }
    private var challenges: [String] { listItems(entry.currentChallenges) }
    private var breakthroughs: [String] { listItems(entry.recentBreakthroughs) }

    var body: some View {
        GrimoireDetailScaffold(eyebrow: "Pathwork", title: entry.chapterTitle, onEdit: { showingEdit = true }) {
            VStack(alignment: .leading, spacing: 10) {
                AsteriumSectionHeader(title: "Status")
                GrimoireStatusBadge(text: entry.currentStatus.displayName)
            }

            GrimoireDetailSection(title: "Started") {
                detailValue(entry.started.formatted(date: .long, time: .omitted))
            }

            GrimoireDetailSection(title: "Focus Area") {
                detailValue(entry.focusArea)
            }

            VStack(alignment: .leading, spacing: 12) {
                GrimoireDetailSection(title: "Why This Path") {
                    detailValue(entry.whyThisPath)
                }

                stackedTileSection(title: "Goals", items: goals, emptyText: "No goals")

                VStack(alignment: .leading, spacing: 8) {
                    AsteriumSectionHeader(title: "Current Practices")
                    gradientChips(practiceItems)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                GrimoireDetailSection(title: "Current Challenges") {
                    gradientBulletRows(challenges, emptyText: "No current challenges")
                }

                GrimoireDetailSection(title: "Recent Breakthroughs") {
                    numberedRows(breakthroughs, emptyText: "No recent breakthroughs")
                }

                studyingResourcesSection
            }

            VStack(alignment: .leading, spacing: 12) {
                AsteriumSectionHeader(title: "Reflection")
                GlassCard {
                    detailValue(entry.reflection)
                }

                if !entry.nextStepsList.isEmpty {
                    GlassCard {
                        numberedRows(Array(entry.nextStepsList.prefix(9)), emptyText: "")
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                AsteriumSectionHeader(title: "Importance")
                GrimoireImportanceDots(value: entry.importance, showsLabel: false)
            }

            VStack(alignment: .leading, spacing: 10) {
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
                let trimmed = entry.additionalNotes.trimmingCharacters(in: .whitespacesAndNewlines)
                Text(trimmed.isEmpty ? "No additional notes" : trimmed)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(trimmed.isEmpty ? LColors.textSecondary : LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .asteriumAdaptivePresentation(isPresented: $showingEdit) {
            PathworkEntryForm(existing: entry)
        }
        .sheet(item: $browserDestination) { destination in
            PathworkSafariView(url: destination.url)
                .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private var studyingResourcesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsteriumSectionHeader(title: "Resources Studying")

            if entry.studyingResources.isEmpty {
                GlassCard {
                    detailValue("No resources")
                }
            } else {
                ForEach(entry.studyingResources) { resource in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(resource.name.uppercased())
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .tracking(1.5)
                                .foregroundStyle(LColors.textSecondary)

                            if !resource.sources.isEmpty {
                                FlowLayout(spacing: 8) {
                                    ForEach(resource.sources) { source in
                                        Button {
                                            openSource(source.link)
                                        } label: {
                                            Text(source.label)
                                                .font(.system(size: 15, weight: .black, design: .rounded))
                                                .foregroundStyle(.white)
                                                .padding(.horizontal, 19)
                                                .padding(.vertical, 11)
                                                .background(Capsule().fill(LGradients.tag.opacity(0.55)))
                                                .overlay { Capsule().strokeBorder(LColors.glassBorder, lineWidth: 1) }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }

                            if !resource.learned.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(resource.learned.indices, id: \.self) { index in
                                        translucentTile(resource.learned[index])
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func gradientChips(_ items: [String]) -> some View {
        FlowLayout(spacing: 8) {
            if items.isEmpty {
                Text("No current practices")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
            } else {
                ForEach(items.indices, id: \.self) { index in
                    Text(items[index])
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(LGradients.tag.opacity(0.55)))
                        .overlay { Capsule().strokeBorder(LColors.glassBorder, lineWidth: 1) }
                }
            }
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
            .overlay { RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.16), lineWidth: 1) }
    }

    private func gradientBulletRows(_ items: [String], emptyText: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if items.isEmpty {
                detailValue(emptyText)
            } else {
                ForEach(items.indices, id: \.self) { index in
                    HStack(alignment: .center, spacing: 12) {
                        Circle()
                            .fill(LGradients.tag)
                            .frame(width: 11, height: 11)
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

    private func numberedRows(_ items: [String], emptyText: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if items.isEmpty {
                if !emptyText.isEmpty { detailValue(emptyText) }
            } else {
                ForEach(items.indices, id: \.self) { index in
                    HStack(alignment: .center, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.bg)
                            .frame(width: 28, height: 28)
                            .background(LGradients.tag, in: Circle())
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

    private func detailValue(_ value: String) -> some View {
        Text(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No details" : value)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? LColors.textSecondary : LColors.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func listItems(_ value: String) -> [String] {
        value.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func openSource(_ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let normalized = trimmed.contains("://") ? trimmed : "https://\(trimmed)"
        guard let url = URL(string: normalized) else { return }
        browserDestination = PathworkBrowserDestination(url: url)
    }
}

private struct PathworkBrowserDestination: Identifiable {
    let id = UUID()
    let url: URL
}

private struct PathworkSafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
