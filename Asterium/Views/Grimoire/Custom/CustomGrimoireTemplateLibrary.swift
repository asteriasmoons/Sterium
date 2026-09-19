//
// CustomGrimoireTemplateLibrary.swift
// Sterium
//

import SwiftUI
import SwiftData

struct CustomGrimoireTemplateLibrary: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CustomGrimoireTemplate.updatedAt, order: .reverse) private var templates: [CustomGrimoireTemplate]

    @State private var showingBuilder = false
    @State private var editingTemplate: CustomGrimoireTemplate?
    @State private var creatingEntryTemplate: CustomGrimoireTemplate?

    private var activeTemplates: [CustomGrimoireTemplate] { templates.filter { !$0.isArchived } }

    var body: some View {
        NavigationStack {
            ZStack {
                AsteriumBackground().ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                        HStack {
                            AsteriumPageHeader(eyebrow: "GRIMOIRE", title: "Custom Entry Types")
                            Spacer()
                            Button { showingBuilder = true } label: { libraryAsset("addwavy", size: 24) }.buttonStyle(.plain)
                            Button { dismiss() } label: { libraryAsset("xmarkwavy", size: 24) }.buttonStyle(.plain)
                        }

                        if activeTemplates.isEmpty {
                            GlassCard {
                                VStack(spacing: 12) {
                                    Image("grimoire").renderingMode(.template).resizable().scaledToFit()
                                        .frame(width: 34, height: 34).foregroundStyle(LGradients.header)
                                    Text("No custom entry types yet")
                                        .font(.system(size: 16, weight: .black, design: .rounded))
                                        .foregroundStyle(LColors.textPrimary)
                                    Text("Use the add button to build one from Asterium's form and display components.")
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundStyle(LColors.textSecondary)
                                        .multilineTextAlignment(.center)
                                }.frame(maxWidth: .infinity).padding(.vertical, 12)
                            }
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(activeTemplates) { template in
                                    GlassCard(padding: 14) {
                                        HStack(spacing: 12) {
                                            Image(template.iconName).renderingMode(.template).resizable().scaledToFit()
                                                .frame(width: 24, height: 24).foregroundStyle(LGradients.header)
                                                .frame(width: 42, height: 42).background(LColors.glassSurface, in: Circle())
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(template.name)
                                                    .font(.system(size: 16, weight: .black, design: .rounded))
                                                    .foregroundStyle(LColors.textPrimary)
                                                Text("Version \(template.currentVersion)")
                                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                                    .foregroundStyle(LColors.textSecondary)
                                            }
                                            Spacer()
                                            Button { creatingEntryTemplate = template } label: { libraryAsset("addwavy", size: 18) }.buttonStyle(.plain)
                                            Button { editingTemplate = template } label: { libraryAsset("pencil", size: 18) }.buttonStyle(.plain)
                                            Button { archive(template) } label: { libraryAsset("trash", size: 17) }.buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, LSpacing.pageHorizontal).padding(.bottom, 100)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .asteriumAdaptivePresentation(isPresented: $showingBuilder) {
                CustomGrimoireTemplateBuilder()
            }
            .asteriumAdaptivePresentation(isPresented: editPresented) {
                if let editingTemplate { CustomGrimoireTemplateBuilder(existing: editingTemplate) }
            }
            .asteriumAdaptivePresentation(isPresented: createEntryPresented) {
                if let creatingEntryTemplate { CustomGrimoireEntryForm(template: creatingEntryTemplate) }
            }
        }
    }

    private var editPresented: Binding<Bool> {
        Binding(get: { editingTemplate != nil }, set: { if !$0 { editingTemplate = nil } })
    }

    private var createEntryPresented: Binding<Bool> {
        Binding(get: { creatingEntryTemplate != nil }, set: { if !$0 { creatingEntryTemplate = nil } })
    }

    private func archive(_ template: CustomGrimoireTemplate) {
        template.isArchived = true
        template.updatedAt = .now
        try? modelContext.save()
    }
}

private func libraryAsset(_ name: String, size: CGFloat) -> some View {
    Image(name).renderingMode(.template).resizable().scaledToFit()
        .frame(width: size, height: size).foregroundStyle(LGradients.header).frame(width: 36, height: 36)
}
