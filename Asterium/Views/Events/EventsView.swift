//
//  EventsView.swift
//  Sterium
//
//  Events tab: Agenda / Timeline / Calendar over a single shared store.
//

import SwiftUI
import SwiftData

struct EventsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \SteriumEvent.startDate) private var events: [SteriumEvent]

    enum Mode: String, CaseIterable, Identifiable {
        case agenda = "Agenda"
        case timeline = "Timeline"
        case calendar = "Calendar"
        var id: String { rawValue }
    }

    @State private var mode: Mode = .agenda
    @State private var focusedDate = Date()
    @State private var showingCreate = false
    @State private var editingEvent: SteriumEvent?
    @State private var selectedEventID: UUID?

    private var selectedEvent: SteriumEvent? {
        events.first { $0.id == selectedEventID }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    header
                    modePicker

                    Group {
                        switch mode {
                        case .agenda:
                            SteriumEventsAgendaView(events: events, onSelect: select)
                        case .timeline:
                            SteriumEventsTimelineView(focusedDate: $focusedDate, events: events, onSelect: select)
                        case .calendar:
                            SteriumEventsCalendarView(focusedDate: $focusedDate, events: events, onSelect: select)
                        }
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 140)
            }
            .scrollIndicators(.hidden)
            .background { AsteriumBackground() }
            .toolbar(.hidden, for: .navigationBar)
            .asteriumAdaptivePresentation(isPresented: $showingCreate) {
                SteriumEventEditorView(startDate: focusedDate)
            }
            .asteriumAdaptivePresentation(
                isPresented: Binding(
                    get: { editingEvent != nil },
                    set: { if $0 == false { editingEvent = nil } }
                )
            ) {
                if let editingEvent {
                    SteriumEventEditorView(event: editingEvent)
                }
            }
            .asteriumAdaptivePresentation(
                isPresented: Binding(
                    get: { selectedEvent != nil },
                    set: { if $0 == false { selectedEventID = nil } }
                )
            ) {
                if let selectedEvent {
                    SteriumEventDetailView(event: selectedEvent) {
                        let event = selectedEvent
                        selectedEventID = nil
                        editingEvent = event
                    }
                }
            }
        }
    }

    private func select(_ eventID: UUID) {
        selectedEventID = eventID
    }

    private var header: some View {
        HStack(alignment: .center) {
            AsteriumPageHeader(eyebrow: "YOUR", title: "Events")
            Spacer()
            Button { showingCreate = true } label: {
                Image("addwavy")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(LGradients.header)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, LSpacing.pageHorizontal)
    }

    private var modePicker: some View {
        HStack(spacing: 10) {
            ForEach(Mode.allCases) { m in
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.82)) { mode = m }
                } label: {
                    Text(m.rawValue)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(mode == m ? LColors.textPrimary : LColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(mode == m ? LColors.glassSurface2 : LColors.glassSurface)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .strokeBorder(mode == m ? AnyShapeStyle(LGradients.header) : AnyShapeStyle(LColors.glassBorder),
                                                      lineWidth: mode == m ? 1.5 : 1)
                                }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, LSpacing.pageHorizontal)
    }
}
