//
//  BetaFeedbackView.swift
//  Sterium
//

import PhotosUI
import SwiftData
import SwiftUI

struct BetaFeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var area = "General"
    @State private var overallExperience = "Good"
    @State private var testedWhat = ""
    @State private var workedWell = ""
    @State private var couldBeBetter = ""
    @State private var unexpected = ""
    @State private var additionalThoughts = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var attachmentData: [Data] = []

    @State private var isSubmitting = false
    @State private var submissionError: String?
    @State private var submittedReportID: String?

    private let areas = [
        "General", "Homepage", "Correspondences", "Spells", "Grimoire",
        "Vision Boards", "Events", "Settings", "Sync / CloudKit", "Notifications", "Share Extension"
    ]

    private let overallExperiences = ["Excellent", "Good", "Okay", "Poor"]

    private var canSubmit: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !area.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !overallExperience.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !testedWhat.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !isSubmitting
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                header
                introCard
                feedbackDetailsSection
                testingSection
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
            AsteriumPageHeader(eyebrow: "VOXIVERSE", title: "Beta Feedback")
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
                Text("Send beta feedback to Voxiverse")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                Text("Share what you tested, what worked, and what needs improvement. Sterium will attach the same automatic diagnostics used for reports.")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var feedbackDetailsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            AsteriumSectionHeader(title: "Feedback Details")
            AsteriumTextField(title: "Title", placeholder: "Short summary of the feedback", text: $title)
            AsteriumPickerField(title: "Area", options: areas, selection: $area)
            AsteriumPickerField(title: "Overall Experience", options: overallExperiences, selection: $overallExperience)
        }
    }

    private var testingSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            AsteriumSectionHeader(title: "Testing Notes")
            AsteriumTextEditor(title: "What Did You Test?", placeholder: "Which feature, workflow, screen, or part of Sterium were you testing?", text: $testedWhat, minHeight: 130)
            AsteriumTextEditor(title: "What Worked Well?", placeholder: "What felt good, clear, useful, or polished?", text: $workedWell, minHeight: 110)
            AsteriumTextEditor(title: "What Could Be Better?", placeholder: "What felt awkward, confusing, incomplete, slow, or visually off?", text: $couldBeBetter, minHeight: 110)
            AsteriumTextEditor(title: "Anything Unexpected?", placeholder: "Anything surprising that was not necessarily a bug?", text: $unexpected, minHeight: 100)
            AsteriumTextEditor(title: "Additional Thoughts", placeholder: "Anything else you want to share?", text: $additionalThoughts, minHeight: 100)
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
                Text("Sterium will include its app version, build number, bundle identifier, device model, iOS version, locale, time zone, and submission time.")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var submitButton: some View {
        Button {
            Task { await submitFeedback() }
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
                Text(isSubmitting ? "Sending…" : "Submit Beta Feedback")
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
                Text("Feedback Sent")
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
    private func submitFeedback() async {
        isSubmitting = true
        submissionError = nil
        submittedReportID = nil

        let payload = VoxiverseBetaFeedbackPayload(
            title: title,
            area: area,
            overallExperience: overallExperience,
            testedWhat: testedWhat,
            workedWell: workedWell,
            couldBeBetter: couldBeBetter,
            unexpected: unexpected,
            additionalThoughts: additionalThoughts,
            attachmentData: attachmentData
        )

        do {
            let result = try await VoxiverseBetaFeedbackService.shared.submit(payload)
            do {
                try saveSubmittedFeedback(reportID: result.reportID, diagnostics: result.diagnostics)
                resetForm()
                dismiss()
            } catch {
                submittedReportID = result.reportID
                submissionError = "The feedback was sent, but its local Submitted copy could not be saved: \(error.localizedDescription)"
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
        area = "General"
        overallExperience = "Good"
        testedWhat = ""
        workedWell = ""
        couldBeBetter = ""
        unexpected = ""
        additionalThoughts = ""
        selectedPhotos = []
        attachmentData = []
        submissionError = nil
        submittedReportID = nil
        isSubmitting = false
    }

    @MainActor
    private func saveSubmittedFeedback(reportID: String, diagnostics: SteriumReportDiagnostics) throws {
        let savedAttachments = attachmentData.prefix(3).enumerated().map { index, data in
            SubmittedReportAttachment(
                displayName: "Screenshot \(index + 1)",
                imageData: data
            )
        }
        let report = SubmittedReport(
            reportID: reportID,
            reportType: "Beta Feedback",
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            descriptionText: testedWhat.trimmingCharacters(in: .whitespacesAndNewlines),
            expectedBehavior: "",
            steps: [],
            category: area,
            severity: "",
            frequency: "",
            overallExperience: overallExperience,
            testedWhat: testedWhat.trimmingCharacters(in: .whitespacesAndNewlines),
            workedWell: workedWell.trimmingCharacters(in: .whitespacesAndNewlines),
            couldBeBetter: couldBeBetter.trimmingCharacters(in: .whitespacesAndNewlines),
            unexpected: unexpected.trimmingCharacters(in: .whitespacesAndNewlines),
            appName: diagnostics.appName,
            appVersion: diagnostics.appVersion,
            buildNumber: diagnostics.buildNumber,
            bundleIdentifier: diagnostics.bundleIdentifier,
            deviceModel: diagnostics.deviceModel,
            iOSVersion: diagnostics.iOSVersion,
            locale: diagnostics.locale,
            timeZone: diagnostics.timeZone,
            screenName: diagnostics.screenName,
            additionalNotes: additionalThoughts.trimmingCharacters(in: .whitespacesAndNewlines),
            submittedAt: diagnostics.submittedAt,
            attachments: savedAttachments
        )
        modelContext.insert(report)
        try modelContext.save()
    }
}
