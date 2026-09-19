//
//  SteriumEventDetailView.swift
//  Sterium
//
//  Rich, sectioned event detail: a hero tile, iconized section headers, and
//  a grid of gradient-bordered data tiles — Sterium's gold take on the
//  Lurelia event layout.
//

import SwiftUI
import SwiftData

struct SteriumEventDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL

    let event: SteriumEvent
    let onEdit: () -> Void

    private let calendar = Calendar.current

    private let tileColumns = [
        GridItem(.flexible(), spacing: 10, alignment: .top),
        GridItem(.flexible(), spacing: 10, alignment: .top)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerRow
                    heroTile
                    scheduleSection
                    if hasMeetingLink { meetingSection }
                    if event.reminder != nil { remindersSection }
                    if hasNotes { detailsSection }
                    deleteButton
                }
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.top, 18)
                .padding(.bottom, 60)
            }
            .scrollIndicators(.hidden)
            .background { AsteriumBackground() }
            .toolbar(.hidden, for: .navigationBar)
            .confirmationDialog("Delete this event?", isPresented: $showingDelete, titleVisibility: .visible) {
                Button("Delete Event", role: .destructive) { deleteEvent() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    @State private var showingDelete = false

    // MARK: - Header row

    private var headerRow: some View {
        HStack(spacing: 10) {
            Text(event.title.isEmpty ? "Event" : event.title)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Spacer(minLength: 8)

            Button { onEdit() } label: {
                Text("Edit")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .padding(.horizontal, 14)
                    .frame(height: 36)
                    .background(LColors.glassSurface, in: Capsule())
                    .overlay { Capsule().strokeBorder(LGradients.header, lineWidth: 1) }
            }
            .buttonStyle(.plain)

            Button { dismiss() } label: {
                Image("xmarkwavy")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(LGradients.header)
                    .frame(width: 40, height: 40)
                    .background(LColors.glassSurface, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Hero tile

    private var heroTile: some View {
        SteriumFrostTile(cornerRadius: 24, padding: 20, alignment: .center) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.10))
                        .frame(width: 96, height: 96)
                    Image(event.displayIcon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 52, height: 52)
                        .foregroundStyle(LGradients.header)
                }

                Text(event.title.isEmpty ? "Untitled Event" : event.title)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Schedule

    private var scheduleSection: some View {
        let start = event.startDate
        let end = event.endDate ?? start.addingTimeInterval(3600)

        return VStack(alignment: .leading, spacing: 10) {
            SteriumEventSectionHeader(title: "Schedule", icon: "ringstarcal")
            LazyVGrid(columns: tileColumns, spacing: 10) {
                dataTile("Start Date", value: start.formatted(date: .abbreviated, time: .omitted))
                dataTile("Start Time", value: event.isAllDay ? "All day" : start.formatted(date: .omitted, time: .shortened))
                dataTile("End Date", value: (event.endDate ?? start).formatted(date: .abbreviated, time: .omitted))
                dataTile("End Time", value: event.isAllDay ? "All day" : end.formatted(date: .omitted, time: .shortened))
                dataTile("Duration", value: event.isAllDay ? "All day" : durationText(end.timeIntervalSince(start)))
                dataTile("Repeats", value: repeatsText)
            }
        }
    }

    private var repeatsText: String {
        guard let summary = event.recurrenceSummary else { return "Never" }
        return summary
    }

    // MARK: - Meeting

    private var meetingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SteriumEventSectionHeader(title: "Meeting", icon: "link")
            VStack(spacing: 10) {
                dataTile("Link", value: event.meetingLink)

                Button {
                    if let url = resolvedMeetingURL { openURL(url) }
                } label: {
                    HStack(spacing: 8) {
                        Image("link")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(LColors.bg)
                        Text("Open Link")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.bg)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 13)
                    .background(LGradients.header, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(resolvedMeetingURL == nil)
                .opacity(resolvedMeetingURL == nil ? 0.5 : 1)
            }
        }
    }

    // MARK: - Reminders

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SteriumEventSectionHeader(title: "Reminders", icon: "bellfill")
            LazyVGrid(columns: tileColumns, spacing: 10) {
                if let reminder = event.reminder {
                    dataTile("Alert", value: reminder.label)
                }
            }
        }
    }

    // MARK: - Details

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SteriumEventSectionHeader(title: "Details", icon: "writefeather")
            SteriumFrostTile {
                VStack(alignment: .leading, spacing: 6) {
                    Text("NOTES")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)
                    Text(event.eventDescription)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    // MARK: - Tile + delete

    private func dataTile(_ label: String, value: String) -> some View {
        SteriumFrostTile {
            VStack(alignment: .leading, spacing: 6) {
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                Text(value)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var deleteButton: some View {
        Button { showingDelete = true } label: {
            HStack(spacing: 10) {
                Image("trash")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                Text("Delete Event")
                    .font(.system(size: 15, weight: .black, design: .rounded))
            }
            .foregroundStyle(LGradients.header)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(LColors.glassBorder, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .padding(.top, 6)
    }

    // MARK: - Helpers

    private var hasMeetingLink: Bool {
        event.meetingLink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    private var hasNotes: Bool {
        event.eventDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    private var resolvedMeetingURL: URL? {
        let raw = event.meetingLink.trimmingCharacters(in: .whitespacesAndNewlines)
        guard raw.isEmpty == false else { return nil }
        if raw.contains("://") { return URL(string: raw) }
        return URL(string: "https://\(raw)")
    }

    private func durationText(_ duration: TimeInterval) -> String {
        let minutes = max(0, Int(duration / 60))
        if minutes < 60 { return "\(minutes) min" }
        let hours = minutes / 60
        let remainder = minutes % 60
        return remainder == 0 ? "\(hours) hr" : "\(hours) hr \(remainder) min"
    }

    private func deleteEvent() {
        SteriumEventNotificationManager.shared.cancelNotifications(for: event)
        modelContext.delete(event)
        try? modelContext.save()
        dismiss()
    }
}
