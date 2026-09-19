//
//  SteriumEventEditorView.swift
//  Sterium
//
//  Create or edit an event: title, description, icon, all-day, start/end,
//  meeting link, reminder, and recurrence.
//

import SwiftUI
import SwiftData

struct SteriumEventEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let event: SteriumEvent?
    private let onDelete: (() -> Void)?

    @State private var title: String
    @State private var eventDescription: String
    @State private var iconName: String
    @State private var isAllDay: Bool
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var meetingLink: String
    @State private var reminderSelection: String

    @State private var repeatSelection: String
    @State private var interval: Int
    @State private var weekdays: Set<Int>
    @State private var endTypeSelection: String
    @State private var recurrenceEndDate: Date
    @State private var occurrenceCount: Int

    @State private var showingDelete = false

    private let reminderNone = "None"
    private let repeatNone = "Does Not Repeat"

    init(event: SteriumEvent? = nil, startDate: Date = Date(), onDelete: (() -> Void)? = nil) {
        self.event = event
        self.onDelete = onDelete

        let baseStart = event?.startDate ?? startDate
        _title = State(initialValue: event?.title ?? "")
        _eventDescription = State(initialValue: event?.eventDescription ?? "")
        _iconName = State(initialValue: event?.iconName ?? "starcal")
        _isAllDay = State(initialValue: event?.isAllDay ?? false)
        _startDate = State(initialValue: baseStart)
        _endDate = State(initialValue: event?.endDate ?? baseStart.addingTimeInterval(3600))
        _meetingLink = State(initialValue: event?.meetingLink ?? "")

        let offset = event?.reminderOffsetMinutes
        _reminderSelection = State(initialValue: offset == nil
            ? "None"
            : (SteriumEventReminder(rawValue: offset!)?.label ?? "None"))

        _repeatSelection = State(initialValue: event?.frequency?.label ?? "Does Not Repeat")
        _interval = State(initialValue: max(1, event?.recurrenceInterval ?? 1))
        _weekdays = State(initialValue: Set((event?.recurrenceWeekdays ?? []).map(\.rawValue)))
        _endTypeSelection = State(initialValue: (event?.recurrenceEndType ?? .never).label)
        _recurrenceEndDate = State(initialValue: event?.recurrenceEndDate ?? baseStart.addingTimeInterval(30 * 86_400))
        _occurrenceCount = State(initialValue: max(1, event?.recurrenceOccurrenceCount ?? 10))
    }

    private var isEditing: Bool { event != nil }

    private var canSave: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    private var reminderOptions: [String] { [reminderNone] + SteriumEventReminder.allCases.map(\.label) }
    private var repeatOptions: [String] { [repeatNone] + SteriumEventFrequency.allCases.map(\.label) }
    private var endTypeOptions: [String] { SteriumEventRecurrenceEndType.allCases.map(\.label) }

    private var isRepeating: Bool { repeatSelection != repeatNone }
    private var isWeekly: Bool { repeatSelection == SteriumEventFrequency.weekly.label }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                    header

                    AsteriumTextField(title: "Title", placeholder: "e.g. Full Moon Ritual...", text: $title)

                    AsteriumTextEditor(
                        title: "Description",
                        placeholder: "Notes about this event... (optional)",
                        text: $eventDescription,
                        minHeight: 90
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        AsteriumSectionHeader(title: "Icon")
                        IconPickerView(selection: $iconName)
                    }

                    toggleRow(title: "All-day event", isOn: $isAllDay)

                    AsteriumDateField(title: "Starts", date: $startDate, includesTime: !isAllDay)
                    AsteriumDateField(title: "Ends", date: $endDate, includesTime: !isAllDay)

                    AsteriumTextField(title: "Meeting Link", placeholder: "https://...", text: $meetingLink)

                    AsteriumPickerField(title: "Reminder", options: reminderOptions, selection: $reminderSelection, leadingAsset: "bellfill")

                    recurrenceSection

                    AsteriumPrimaryButton(title: isEditing ? "Save Changes" : "Create Event", asset: "starcal") {
                        save()
                    }
                    .disabled(canSave == false)
                    .opacity(canSave ? 1 : 0.55)

                    if isEditing {
                        deleteButton
                    }
                }
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.bottom, 140)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.never)
            .background { AsteriumBackground() }
            .dismissesKeyboardOnOutsideTap()
            .toolbar(.hidden, for: .navigationBar)
            .confirmationDialog("Delete this event?", isPresented: $showingDelete, titleVisibility: .visible) {
                Button("Delete Event", role: .destructive) { deleteEvent() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    // MARK: - Recurrence

    @ViewBuilder
    private var recurrenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsteriumPickerField(title: "Repeat", options: repeatOptions, selection: $repeatSelection, leadingAsset: "repeatarrows")

            if isRepeating {
                stepperRow(title: "Every", value: $interval, range: 1...99, unit: intervalUnit)

                if isWeekly {
                    weekdayPicker
                }

                AsteriumPickerField(title: "Ends", options: endTypeOptions, selection: $endTypeSelection, leadingAsset: "clockwavy")

                if endTypeSelection == SteriumEventRecurrenceEndType.onDate.label {
                    AsteriumDateField(title: "End Date", date: $recurrenceEndDate, includesTime: false)
                } else if endTypeSelection == SteriumEventRecurrenceEndType.afterOccurrences.label {
                    stepperRow(title: "Occurrences", value: $occurrenceCount, range: 1...365, unit: occurrenceCount == 1 ? "time" : "times")
                }
            }
        }
    }

    private var intervalUnit: String {
        switch repeatSelection {
        case SteriumEventFrequency.daily.label: return interval == 1 ? "day" : "days"
        case SteriumEventFrequency.weekly.label: return interval == 1 ? "week" : "weeks"
        case SteriumEventFrequency.monthly.label: return interval == 1 ? "month" : "months"
        case SteriumEventFrequency.yearly.label: return interval == 1 ? "year" : "years"
        default: return ""
        }
    }

    private var weekdayPicker: some View {
        HStack(spacing: 7) {
            ForEach(SteriumEventWeekday.allCases) { weekday in
                let isOn = weekdays.contains(weekday.rawValue)
                Button {
                    if isOn { weekdays.remove(weekday.rawValue) } else { weekdays.insert(weekday.rawValue) }
                } label: {
                    Text(weekday.shortLabel)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(isOn ? LColors.bg : LColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(isOn ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.glassSurface))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(LColors.glassBorder, lineWidth: isOn ? 0 : 1)
                                }
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Reusable controls

    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) { isOn.wrappedValue.toggle() }
        } label: {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                Spacer()
                ZStack(alignment: isOn.wrappedValue ? .trailing : .leading) {
                    Capsule()
                        .fill(isOn.wrappedValue ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.glassSurface2))
                        .frame(width: 46, height: 28)
                        .overlay { Capsule().strokeBorder(LColors.glassBorder, lineWidth: 1) }
                    Circle()
                        .fill(LColors.textPrimary)
                        .frame(width: 22, height: 22)
                        .padding(.horizontal, 3)
                }
            }
            .padding(14)
            .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: LSpacing.inputRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: LSpacing.inputRadius, style: .continuous)
                    .strokeBorder(LColors.glassBorder, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private func stepperRow(title: String, value: Binding<Int>, range: ClosedRange<Int>, unit: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(LColors.textPrimary)
            Spacer()
            HStack(spacing: 14) {
                stepButton("minuswavy") {
                    if value.wrappedValue > range.lowerBound { value.wrappedValue -= 1 }
                }
                Text("\(value.wrappedValue) \(unit)")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .frame(minWidth: 74)
                    .multilineTextAlignment(.center)
                stepButton("addwavy") {
                    if value.wrappedValue < range.upperBound { value.wrappedValue += 1 }
                }
            }
        }
        .padding(14)
        .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: LSpacing.inputRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: LSpacing.inputRadius, style: .continuous)
                .strokeBorder(LColors.glassBorder, lineWidth: 1)
        }
    }

    private func stepButton(_ asset: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(asset)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(LGradients.header)
                .frame(width: 32, height: 32)
                .background(LColors.glassSurface2, in: Circle())
        }
        .buttonStyle(.plain)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(isEditing ? "EDIT EVENT" : "NEW EVENT")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(LGradients.header)
                Text(isEditing ? "Edit Event" : "Event")
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
            .padding(.vertical, 14)
            .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: LSpacing.buttonRadius))
            .overlay {
                RoundedRectangle(cornerRadius: LSpacing.buttonRadius)
                    .strokeBorder(LColors.glassBorder, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Persistence

    private func save() {
        let target = event ?? SteriumEvent()

        target.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        target.eventDescription = eventDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        target.iconName = iconName
        target.isAllDay = isAllDay
        target.startDate = startDate
        target.endDate = endDate > startDate ? endDate : nil
        target.meetingLink = meetingLink.trimmingCharacters(in: .whitespacesAndNewlines)
        target.reminderOffsetMinutes = SteriumEventReminder.allCases.first { $0.label == reminderSelection }?.rawValue

        // Recurrence
        if let frequency = SteriumEventFrequency.allCases.first(where: { $0.label == repeatSelection }) {
            target.frequency = frequency
            target.recurrenceInterval = max(1, interval)
            target.recurrenceWeekdays = weekdays.sorted().compactMap { SteriumEventWeekday(rawValue: $0) }
            if let endType = SteriumEventRecurrenceEndType.allCases.first(where: { $0.label == endTypeSelection }) {
                target.recurrenceEndType = endType
            }
            target.recurrenceEndDate = target.recurrenceEndType == .onDate ? recurrenceEndDate : nil
            target.recurrenceOccurrenceCount = target.recurrenceEndType == .afterOccurrences ? max(1, occurrenceCount) : nil
        } else {
            target.frequency = nil
            target.recurrenceWeekdays = []
            target.recurrenceEndType = .never
            target.recurrenceEndDate = nil
            target.recurrenceOccurrenceCount = nil
        }

        target.updatedAt = Date()

        if isEditing == false {
            modelContext.insert(target)
        }
        try? modelContext.save()

        SteriumEventNotificationManager.shared.scheduleNotifications(for: target)
        dismiss()
    }

    private func deleteEvent() {
        guard let event else { return }
        SteriumEventNotificationManager.shared.cancelNotifications(for: event)
        modelContext.delete(event)
        try? modelContext.save()
        onDelete?()
        dismiss()
    }
}
