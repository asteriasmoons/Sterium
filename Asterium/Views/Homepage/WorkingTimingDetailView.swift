//
//  WorkingTimingDetailView.swift
//  Sterium
//
//  Result sheet for the Working Timing Finder. Shows the best upcoming window,
//  the conditions that produced it, the Major Transits for that window, a
//  deterministic "Why This Timing" built from the engine's recorded reasons,
//  and the ranked alternatives. The same view renders both a freshly generated
//  result and a persisted snapshot (isSavedSnapshot) — a snapshot never
//  recalculates and hides the Save action.
//

import SwiftUI
import SwiftData

struct WorkingTimingDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let result: WorkingTimingResult
    /// When true, this view is showing a persisted snapshot: the Save action is
    /// hidden (it is already saved) and nothing is ever recalculated.
    var isSavedSnapshot: Bool = false

    @State private var expandedAlternatives: Set<UUID> = []
    @State private var isSaved = false

    private let tileColumns = [
        GridItem(.flexible(), spacing: 12, alignment: .top),
        GridItem(.flexible(), spacing: 12, alignment: .top)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                    header
                    bestCard
                    conditionsSection(for: result.best)
                    majorTransitsSection(for: result.best)
                    whySection(for: result.best)

                    if result.alternatives.isEmpty == false {
                        alternativesSection
                    }
                }
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
            .background { AsteriumBackground() }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear { refreshSavedState() }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("WORKING TIMING")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(LGradients.header)
                Text(result.profile.primaryIntention.isEmpty ? "Best Timing" : result.profile.primaryIntention)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            HStack(spacing: 10) {
                if isSavedSnapshot == false {
                    saveButton
                }
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
            .padding(.top, 2)
        }
        .padding(.top, 16)
    }

    private var saveButton: some View {
        Button {
            saveCurrentResult()
        } label: {
            Image(isSaved ? "checkwavy" : "bookmark")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundStyle(LGradients.header)
                .frame(width: 42, height: 42)
                .background(LColors.glassSurface, in: Circle())
                .overlay {
                    Circle().strokeBorder(
                        isSaved ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(Color.clear),
                        lineWidth: 1.5
                    )
                }
        }
        .buttonStyle(.plain)
        .disabled(isSaved)
        .animation(.spring(response: 0.28, dampingFraction: 0.8), value: isSaved)
    }

    private func refreshSavedState() {
        guard isSavedSnapshot == false else { return }
        let hash = result.contentHash()
        guard hash.isEmpty == false else { return }
        var descriptor = FetchDescriptor<SavedWorkingTiming>(
            predicate: #Predicate { $0.contentHash == hash }
        )
        descriptor.fetchLimit = 1
        if let matches = try? modelContext.fetch(descriptor), matches.isEmpty == false {
            isSaved = true
        }
    }

    private func saveCurrentResult() {
        guard isSavedSnapshot == false, isSaved == false else { return }

        // Prevent saving the exact same generated result twice, and never
        // overwrite a different saved result.
        let hash = result.contentHash()
        if hash.isEmpty == false {
            var descriptor = FetchDescriptor<SavedWorkingTiming>(
                predicate: #Predicate { $0.contentHash == hash }
            )
            descriptor.fetchLimit = 1
            if let matches = try? modelContext.fetch(descriptor), matches.isEmpty == false {
                isSaved = true
                return
            }
        }

        guard let snapshot = try? SavedWorkingTiming.make(from: result) else { return }
        modelContext.insert(snapshot)
        try? modelContext.save()
        withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
            isSaved = true
        }
    }

    // MARK: - Best card

    private var bestCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image("goalsparkle")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(LGradients.header)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("BEST TIMING")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundStyle(LGradients.header)
                        Text(dateText(result.best))
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }

                LazyVGrid(columns: tileColumns, spacing: 12) {
                    tile("Time", value: timeText(result.best))
                    tile("Strength", value: result.best.strengthLabel)
                }

                if result.profile.interpretedIntention.isEmpty == false {
                    labeledParagraph("INTERPRETED INTENTION", result.profile.interpretedIntention)
                }

                if result.profile.secondaryIntentions.isEmpty == false {
                    labeledParagraph("ALSO SUPPORTS", result.profile.secondaryIntentions.joined(separator: " · "))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Conditions

    private func conditionsSection(for window: WorkingTimingWindow) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("hourglassfill", "Conditions")
            let c = window.conditions
            LazyVGrid(columns: tileColumns, spacing: 12) {
                tile("Moon Phase", value: c.moonPhase)
                tile("Moon Sign", value: c.moonSign)
                tile("Planetary Day", value: c.planetaryDay.displayName)
                tile("Planetary Hour", value: c.planetaryHour?.displayName ?? "Location needed")
                tile("Numerology", value: "Universal Day \(c.numerology)")
            }
        }
    }

    // MARK: - Major Transits

    private func majorTransitsSection(for window: WorkingTimingWindow) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("planet", "Major Transits")
            let transits = window.conditions.transits
            if transits.isEmpty {
                GlassCard {
                    HStack(alignment: .top, spacing: 12) {
                        Image("planet")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundStyle(LGradients.header)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("No major transits")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundStyle(LColors.textPrimary)
                            Text("The sky is quiet for this window \u{2014} no major aspects are active.")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(LColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(transits) { transit in
                        transitRow(transit)
                    }
                }
            }
        }
    }

    private func transitRow(_ transit: AstrologyTransit) -> some View {
        HStack(spacing: 12) {
            Image(transit.aspect.assetName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundStyle(LGradients.header)
            Text(transit.title)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(LColors.glassBorder, lineWidth: 1)
        }
    }

    // MARK: - Why

    private func whySection(for window: WorkingTimingWindow) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("sparkle", "Why This Timing")
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    if window.reasons.isEmpty {
                        Text("This window ranked highest among the next 14 days.")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(LColors.textSecondary)
                    } else {
                        ForEach(window.supportingReasons) { reasonRow($0) }
                        ForEach(window.challengingReasons) { reasonRow($0) }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func reasonRow(_ reason: WorkingTimingReason) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(reason.isPositive ? "checkwavy" : "warnwavy")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(reason.isPositive ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.textSecondary))
                .padding(.top, 1)
            Text(reason.text)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(LColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }

    // MARK: - Alternatives

    private var alternativesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("dotscal", "Other Windows")
            VStack(spacing: 12) {
                ForEach(result.alternatives) { window in
                    alternativeCard(window)
                }
            }
        }
    }

    private func alternativeCard(_ window: WorkingTimingWindow) -> some View {
        let isExpanded = expandedAlternatives.contains(window.id)
        return GlassCard(cornerRadius: 18, padding: 14) {
            VStack(alignment: .leading, spacing: 12) {
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                        if isExpanded { expandedAlternatives.remove(window.id) }
                        else { expandedAlternatives.insert(window.id) }
                    }
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(dateText(window))
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundStyle(LColors.textPrimary)
                            Text("\(timeText(window)) · \(window.strengthLabel)")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(LColors.textSecondary)
                        }
                        Spacer()
                        Image(isExpanded ? "chevup" : "chevdown")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(LGradients.header)
                    }
                }
                .buttonStyle(.plain)

                if isExpanded {
                    LazyVGrid(columns: tileColumns, spacing: 12) {
                        tile("Planetary Day", value: window.conditions.planetaryDay.displayName)
                        tile("Planetary Hour", value: window.conditions.planetaryHour?.displayName ?? "Location needed")
                        tile("Moon Phase", value: window.conditions.moonPhase)
                        tile("Numerology", value: "Universal Day \(window.conditions.numerology)")
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(window.supportingReasons) { reasonRow($0) }
                        ForEach(window.challengingReasons) { reasonRow($0) }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Building blocks

    private func sectionHeader(_ icon: String, _ title: String) -> some View {
        HStack(spacing: 10) {
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(LGradients.header)
            Text(title)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textPrimary)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 4)
    }

    private func tile(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textSecondary)
            Text(value)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
        .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14).strokeBorder(LColors.glassBorder, lineWidth: 1)
        }
    }

    private func labeledParagraph(_ label: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textSecondary)
            Text(text)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(LColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Formatting

    private func dateText(_ window: WorkingTimingWindow) -> String {
        window.conditions.start.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }

    private func timeText(_ window: WorkingTimingWindow) -> String {
        guard window.conditions.planetaryHour != nil else { return "All day" }
        let start = window.conditions.start.formatted(date: .omitted, time: .shortened)
        let end = window.conditions.end.formatted(date: .omitted, time: .shortened)
        return "\(start) – \(end)"
    }
}
