//
//  GrimoireUniversalFields.swift
//  Sterium
//

import SwiftUI

struct GrimoireUniversalFields: View {
    @Binding var importance: Int
    @Binding var tags: [String]
    @Binding var attachments: [GrimoireAttachment]
    @Binding var relatedEntries: [GrimoireRelatedEntry]
    @Binding var additionalNotes: String
    var showsSectionTitle = true

    var body: some View {
        VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
            if showsSectionTitle {
                AsteriumSectionHeader(title: "Details")
            }

            GrimoireImportancePicker(importance: $importance)

            GrimoireTagsField(tags: $tags)

            GrimoireAttachmentsField(attachments: $attachments)

            GrimoireRelatedEntriesField(relatedEntries: $relatedEntries)

            AsteriumTextEditor(
                title: "Additional Notes",
                placeholder: "Any extra thoughts...",
                text: $additionalNotes,
                minHeight: 100
            )
        }
    }
}
