//
//  SavedTimingsView.swift
//  Sterium
//
//  Full-page destination listing saved Working Timing snapshots, split into
//  Upcoming (best-timing window not finished) and Past (already passed).
//  Tapping a summary opens the SAME WorkingTimingDetailView using the stored
//  snapshot — nothing is recalculated.
//

import SwiftUI
import SwiftData
import Combine

struct SavedTimingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \SavedWorkingTiming.bestStart)
    private var savedTimings: [SavedWorkingTiming]

    @State private var now = Date()
    @State private var selected: SavedWorkingTiming?

    // Best-timing window not finished yet → Upcoming; otherwise Past.
    private var upcoming: [SavedWorkingTiming] {
        savedTimings
            .filter { $0.bestEnd > now }
            .sorted { $0.bestStart < $1.bestStart }   // soonest first
    }

    private var past: [SavedWorkingTiming] {
        savedTimings
            .filter { $0.bestEnd <= now }
            .sorted { $0.bestStart > $1.bestStart }    // most recent first
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                pageHeader

                if savedTimings.isEmpty {
                    emptyState
                } else {
                    if upcoming.isEmpty == false {
                        section(title: "Upcoming", timings: upcoming)
                    }
                    if past.isEmpty == false {
                        section(title: "Past", timings: past)
                    }
                }
            }
            .padding(.horizontal, LSpacing.pageHorizontal)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background { AsteriumBackground() }
        .toolbar(.hidden, for: .navigationBar)
        .onReceive(
            Timer.publish(every: 60, on: .main, in: .common).autoconnect()
        ) { date in
            now = date
        }
        .asteriumAdaptivePresentation(
            isPresented: Binding(
                get: { selected != nil },
                set: { if $0 == false { selected = nil } }
            )
        ) {
            if let selected, let result = selected.decodedResult {
                WorkingTimingDetailView(result: result, isSavedSnapshot: true)
            }
        }
    }

    // MARK: - Header

    private var pageHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("WORKING TIMING")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(LGradients.header)
                Text("Saved Timings")
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
            .padding(.top, 2)
        }
        .padding(.top, 16)
    }

    // MARK: - Sections

    private func section(title: String, timings: [SavedWorkingTiming]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            AsteriumSectionHeader(title: title)
            VStack(spacing: 12) {
                ForEach(timings) { timing in
                    Button {
                        selected = timing
                    } label: {
                        summaryCard(timing)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            delete(timing)
                        } label: {
                            Text("Delete Saved Timing")
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        GlassCard {
            HStack(alignment: .top, spacing: 12) {
                Image("bookmark")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(LGradients.header)
                VStack(alignment: .leading, spacing: 4) {
                    Text("No saved timings yet")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                    Text("Save a timing from the Working Timing details and it will appear here.")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Summary card

    private func summaryCard(_ timing: SavedWorkingTiming) -> some View {
        GlassCard(cornerRadius: 18, padding: 14) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image("goalsparkle")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(LGradients.header)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(timing.primaryIntention.isEmpty ? "Working Timing" : timing.primaryIntention)
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(dateText(timing))
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(LColors.textSecondary)
                    }
                    Spacer(minLength: 0)
                    Image("rightwavy")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(LGradients.header)
                        .padding(.top, 2)
                }

                HStack(spacing: 10) {
                    summaryPill(label: "TIME", value: timeText(timing), asset: "clockwavy")
                    summaryPill(label: "STRENGTH", value: timing.strengthLabel, asset: "sparkle")
                }

                if timing.planetaryDayName.isEmpty == false {
                    summaryPill(
                        label: "PLANETARY DAY",
                        value: planetaryText(timing),
                        asset: "ringstarcal"
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func summaryPill(label: String, value: String, asset: String) -> some View {
        HStack(spacing: 9) {
            Image(asset)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(LGradients.header)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                Text(value)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(LColors.glassBorder, lineWidth: 1)
        }
    }

    // MARK: - Actions

    private func delete(_ timing: SavedWorkingTiming) {
        if selected?.id == timing.id { selected = nil }
        modelContext.delete(timing)
        try? modelContext.save()
    }

    // MARK: - Formatting

    private func dateText(_ timing: SavedWorkingTiming) -> String {
        timing.bestStart.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }

    private func timeText(_ timing: SavedWorkingTiming) -> String {
        guard timing.planetaryHourName.isEmpty == false else { return "All day" }
        let start = timing.bestStart.formatted(date: .omitted, time: .shortened)
        let end = timing.bestEnd.formatted(date: .omitted, time: .shortened)
        return "\(start) \u{2013} \(end)"
    }

    private func planetaryText(_ timing: SavedWorkingTiming) -> String {
        if timing.planetaryHourName.isEmpty {
            return timing.planetaryDayName
        }
        return "\(timing.planetaryDayName) \u{00B7} \(timing.planetaryHourName) hr"
    }
}
