//
//  BugReportView.swift
//  Sterium
//

import PhotosUI
import SwiftUI
import SwiftData

struct BugReportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var descriptionText = ""
    @State private var expectedBehavior = ""
    @State private var steps = [""]
    @State private var category = "General"
    @State private var severity = "Medium"
    @State private var frequency = "Every Time"
    @State private var additionalNotes = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var attachmentData: [Data] = []

    @State private var isSubmitting = false
    @State private var submissionError: String?
    @State private var submittedReportID: String?

    private let categories = [
        "General", "Homepage", "Correspondences", "Spells", "Grimoire",
        "Vision Boards", "Events", "Settings", "Sync / CloudKit", "Notifications", "Share Extension"
    ]

    private let severities = ["Low", "Medium", "High", "Critical"]
    private let frequencies = ["Once", "Sometimes", "Often", "Every Time"]

    private var canSubmit: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        steps.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } &&
        !isSubmitting
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                header
                introCard
                reportDetailsSection
                behaviorSection
                reproductionSection
                attachmentsSection
                diagnosticsCard

                if let submissionError {
                    errorCard(submissionError)
                }

                if let submittedReportID {
                    successCard(submittedReportID)
                }

                submitButton
            }
            .padding(.horizontal, LSpacing.pageHorizontal)
            .padding(.bottom, 80)
        }
        .scrollIndicators(.hidden)
        .background { AsteriumBackground() }
        .dismissesKeyboardOnOutsideTap()
        .onChange(of: selectedPhotos) { _, newItems in
            Task { await loadAttachments(from: newItems) }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            AsteriumPageHeader(eyebrow: "VOXIVERSE", title: "Report a Bug")
            Spacer()
            Button { dismiss() } label: {
                Image("xmarkwavy")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 17, height: 17)
                    .foregroundStyle(LGradients.header)
                    .frame(width: 44, height: 44)
                    .background(LColors.glassSurface, in: Circle())
                    .overlay { Circle().strokeBorder(LColors.glassBorder, lineWidth: 1) }
            }
            .buttonStyle(.plain)
            .padding(.top, 16)
        }
    }

    private var introCard: some View {
        GlassCard(cornerRadius: 22) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Send this directly to Voxiverse")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                Text("Describe exactly what happened. Sterium will attach the app version, build, device, iOS version, locale, time zone, and submission time automatically.")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var reportDetailsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            AsteriumSectionHeader(title: "Report Details")
            AsteriumTextField(title: "Title", placeholder: "Short description of the bug", text: $title)
            AsteriumPickerField(title: "Area", options: categories, selection: $category)
            AsteriumPickerField(title: "Severity", options: severities, selection: $severity)
            AsteriumPickerField(title: "Frequency", options: frequencies, selection: $frequency)
        }
    }

    private var behaviorSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            AsteriumSectionHeader(title: "What Happened")
            AsteriumTextEditor(title: "Description", placeholder: "Tell me what happened, what you were doing, and what went wrong.", text: $descriptionText, minHeight: 150)
            AsteriumTextEditor(title: "Expected Behavior", placeholder: "What did you expect Sterium to do instead?", text: $expectedBehavior, minHeight: 110)
        }
    }

    private var reproductionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            AsteriumSectionHeader(title: "Reproduce the Bug")
            AsteriumDynamicStepsField(title: "Steps to Reproduce", steps: $steps, maxSteps: 10)
            AsteriumTextEditor(title: "Additional Notes", placeholder: "Anything else that might help explain the problem?", text: $additionalNotes, minHeight: 100)
        }
    }

    private var attachmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsteriumSectionHeader(title: "Attachments")

            PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 3, matching: .images) {
                GlassCard(cornerRadius: 18) {
                    HStack(spacing: 14) {
                        Image("film")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundStyle(LGradients.header)

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Add Screenshots")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundStyle(LColors.textPrimary)
                            Text("Up to 3 images")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(LColors.textSecondary)
                        }
                        Spacer()
                        Text("\(attachmentData.count)/3")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.textSecondary)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var diagnosticsCard: some View {
        GlassCard(cornerRadius: 22) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Automatic Diagnostics")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                Text("Sterium will include its app version, build number, bundle identifier, device model, iOS version, locale, time zone, and the screen this report came from.")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var submitButton: some View {
        Button {
            Task { await submitReport() }
        } label: {
            HStack(spacing: 10) {
                if isSubmitting {
                    ProgressView()
                        .tint(LColors.bg)
                } else {
                    Image("sharebutton")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 17, height: 17)
                }
                Text(isSubmitting ? "Sending…" : "Submit Bug Report")
                    .font(.system(size: 16, weight: .black, design: .rounded))
            }
            .foregroundStyle(LColors.bg)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(LGradients.header, in: RoundedRectangle(cornerRadius: LSpacing.buttonRadius))
            .opacity(canSubmit ? 1 : 0.45)
        }
        .buttonStyle(.plain)
        .disabled(!canSubmit)
    }

    private func errorCard(_ message: String) -> some View {
        GlassCard(cornerRadius: 18) {
            Text(message)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(LColors.danger)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func successCard(_ reportID: String) -> some View {
        GlassCard(cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Report Sent")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.success)
                Text("Voxiverse report ID: \(reportID)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
            }
        }
    }

    private func loadAttachments(from items: [PhotosPickerItem]) async {
        var loaded: [Data] = []
        for item in items.prefix(3) {
            if let data = try? await item.loadTransferable(type: Data.self) {
                loaded.append(data)
            }
        }
        await MainActor.run { attachmentData = loaded }
    }

    @MainActor
    private func submitReport() async {
        isSubmitting = true
        submissionError = nil
        submittedReportID = nil

        let payload = VoxiverseBugReportPayload(
            title: title,
            description: descriptionText,
            expectedBehavior: expectedBehavior,
            steps: steps,
            category: category,
            severity: severity,
            frequency: frequency,
            additionalNotes: additionalNotes,
            attachmentData: attachmentData
        )

        do {
            let reportID = try await VoxiverseBugReportService.shared.submit(payload)
            do {
                try saveSubmittedReport(reportID: reportID)
                resetForm()
                dismiss()
            } catch {
                submittedReportID = reportID
                submissionError = "The report was sent, but its local Submitted copy could not be saved: \(error.localizedDescription)"
                isSubmitting = false
            }
        } catch {
            submissionError = error.localizedDescription
            isSubmitting = false
        }
    }

    @MainActor
    private func resetForm() {
        title = ""
        descriptionText = ""
        expectedBehavior = ""
        steps = [""]
        category = "General"
        severity = "Medium"
        frequency = "Every Time"
        additionalNotes = ""
        selectedPhotos = []
        attachmentData = []
        submissionError = nil
        submittedReportID = nil
        isSubmitting = false
    }

    @MainActor
    private func saveSubmittedReport(reportID: String) throws {
        let savedAttachments = attachmentData.prefix(3).enumerated().map { index, data in
            SubmittedReportAttachment(
                displayName: "Screenshot \(index + 1)",
                imageData: data
            )
        }
        let report = SubmittedReport(
            reportID: reportID,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            descriptionText: descriptionText.trimmingCharacters(in: .whitespacesAndNewlines),
            expectedBehavior: expectedBehavior.trimmingCharacters(in: .whitespacesAndNewlines),
            steps: steps.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty },
            category: category,
            severity: severity,
            frequency: frequency,
            additionalNotes: additionalNotes.trimmingCharacters(in: .whitespacesAndNewlines),
            attachments: savedAttachments
        )
        modelContext.insert(report)
        try modelContext.save()
    }
}
