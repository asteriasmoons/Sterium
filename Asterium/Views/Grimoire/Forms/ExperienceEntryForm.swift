
//
//  ExperienceEntryForm.swift
//  Asterium
//

import SwiftUI
import SwiftData

struct ExperienceEntryForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let existing: ExperienceEntry?

    @State private var title: String
    @State private var date: Date
    @State private var content: String

    @State private var importance: Int
    @State private var tags: [String]
    @State private var attachments: [GrimoireAttachment]
    @State private var relatedEntries: [GrimoireRelatedEntry]
    @State private var additionalNotes: String

    init(existing: ExperienceEntry? = nil) {
        self.existing = existing
        _title = State(initialValue: existing?.title ?? "")
        _date = State(initialValue: existing?.date ?? .now)
        _content = State(initialValue: existing?.content ?? "")
        _importance = State(initialValue: existing?.importance ?? 1)
        _tags = State(initialValue: existing?.tags ?? [])
        _attachments = State(initialValue: existing?.attachments ?? [])
        _relatedEntries = State(initialValue: existing?.relatedEntries ?? [])
        _additionalNotes = State(initialValue: existing?.additionalNotes ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                    HStack(alignment: .center) {
                        Text("Experience")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)

                        Spacer()

                        Button { dismiss() } label: {
                            Image("xmarkwavy")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(LGradients.header)
                        }
                        .buttonStyle(.plain)
                    }

                    AsteriumTextField(title: "Title", placeholder: "Entry title...", text: $title)

                    AsteriumDateField(title: "Date", date: $date)

                    AsteriumTextEditor(
                        title: "Content",
                        placeholder: "Describe your experience...",
                        text: $content,
                        minHeight: 250
                    )

                    GrimoireUniversalFields(
                        importance: $importance,
                        tags: $tags,
                        attachments: $attachments,
                        relatedEntries: $relatedEntries,
                        additionalNotes: $additionalNotes
                    )

                    AsteriumPrimaryButton(title: "Save Entry") {
                        save()
                    }
                }
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.immediately)
            .simultaneousGesture(
                TapGesture().onEnded {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }
            )
            .background { AsteriumBackground() }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func save() {
        if let existing {
            existing.title = title
            existing.date = date
            existing.content = content
            existing.importance = importance
            existing.tags = tags
            existing.attachments = attachments
            existing.relatedEntries = relatedEntries
            existing.additionalNotes = additionalNotes
            existing.updatedAt = .now
        } else {
            let entry = ExperienceEntry(
                title: title,
                date: date,
                content: content,
                importance: importance,
                tags: tags,
                attachments: attachments,
                relatedEntries: relatedEntries,
                additionalNotes: additionalNotes,
                createdAt: .now,
                updatedAt: .now
            )
            modelContext.insert(entry)
        }
        dismiss()
    }
}
