//
//  FeatureRequestView.swift
//  Sterium
//

import PhotosUI
import SwiftData
import SwiftUI

struct FeatureRequestView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var featureTitle = ""
    @State private var area = "General"
    @State private var featureType = "New Feature"
    @State private var importance = "Useful"
    @State private var intendedAudience = "Everyone"
    @State private var featureDescription = ""
    @State private var imaginedWorkflow = ""
    @State private var desiredLocation = "Existing Area"
    @State private var relatedExistingFeature = "None"
    @State private var problemAddressed = ""
    @State private var desiredResult = ""
    @State private var requiresSavedData = "Unsure"
    @State private var needsNotifications = "Unsure"
    @State private var needsSharing = "Unsure"
    @State private var needsAI = "Unsure"
    @State private var additionalDetails = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var attachmentData: [Data] = []

    @State private var isSubmitting = false
    @State private var submissionError: String?

    private let areas = [
        "General", "Homepage", "Correspondences", "Spells", "Grimoire",
        "Vision Boards", "Events", "Settings", "Sync & CloudKit", "Notifications", "Share Extension"
    ]

    private let featureTypes = [
        "New Feature", "Enhancement to Existing Feature", "New Tool",
        "New View or Screen", "New Integration", "Automation",
        "Customization Option", "Accessibility", "Import / Export",
        "Widget", "Other"
    ]

    private let importanceOptions = ["Nice to Have", "Useful", "Important", "Essential"]

    private let audienceOptions = [
        "Everyone", "New Practitioners", "Experienced Practitioners",
        "Personal Practice", "Specific Practice / Path", "Accessibility Need", "Other"
    ]

    private let locationOptions = ["Existing Area", "New Screen", "Homepage", "Settings", "App-Wide", "Unsure"]

    private let relatedFeatureOptions = [
        "None", "Correspondences", "Spells", "Grimoire", "Vision Boards",
        "Events", "Notifications", "CloudKit / Sync", "Share Extension", "Other"
    ]

    private let yesNoUnsureOptions = ["Yes", "No", "Unsure"]
    private let yesNoOptionalUnsureOptions = ["Yes", "No", "Optional", "Unsure"]

    private var canSubmit: Bool {
        !featureTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !area.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !featureType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !importance.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !intendedAudience.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !featureDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !imaginedWorkflow.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !desiredLocation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !problemAddressed.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !desiredResult.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !requiresSavedData.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !needsNotifications.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !needsSharing.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !needsAI.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !isSubmitting
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                header
                introCard
                featureDetailsSection
                featureProposalSection
                requirementsSection
                attachmentsSection
                diagnosticsCard

                if let submissionError {
                    errorCard(submissionError)
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
            AsteriumPageHeader(eyebrow: "VOXIVERSE", title: "Feature Request")
            Spacer()
            Button { dismiss() } label: {
                Image("xmarkwavy")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(LGradients.header)
            }
            .buttonStyle(.plain)
            .padding(.top, 16)
        }
    }

    private var introCard: some View {
        GlassCard(cornerRadius: 22) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Send a feature request to Voxiverse")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                Text("Describe the feature, where it should live, how it should work, and what it would make possible in Sterium.")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var featureDetailsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            AsteriumSectionHeader(title: "Feature Details")
            AsteriumTextField(title: "Feature Title", placeholder: "Short clear name for the feature", text: $featureTitle)
            AsteriumPickerField(title: "Area", options: areas, selection: $area)
            AsteriumPickerField(title: "Feature Type", options: featureTypes, selection: $featureType)
            AsteriumPickerField(title: "Importance", options: importanceOptions, selection: $importance)
            AsteriumPickerField(title: "Who Is This For?", options: audienceOptions, selection: $intendedAudience)
        }
    }

    private var featureProposalSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            AsteriumSectionHeader(title: "Feature Proposal")
            AsteriumTextEditor(
                title: "What Should the Feature Do?",
                placeholder: "Describe the actual capability you want added and what you should be able to accomplish with it.",
                text: $featureDescription,
                minHeight: 130
            )
            AsteriumTextEditor(
                title: "How Should It Work?",
                placeholder: "Describe how you imagine using the feature from beginning to end, including what you would tap, enter, select, create, or receive.",
                text: $imaginedWorkflow,
                minHeight: 130
            )
            AsteriumPickerField(title: "Where Should It Live?", options: locationOptions, selection: $desiredLocation)
            AsteriumPickerField(title: "Related Existing Feature", options: relatedFeatureOptions, selection: $relatedExistingFeature)
            AsteriumTextEditor(
                title: "What Problem or Limitation Does It Address?",
                placeholder: "Explain what you currently cannot do, what feels limited, or what this feature would make easier or better.",
                text: $problemAddressed,
                minHeight: 130
            )
            AsteriumTextEditor(
                title: "Desired Result",
                placeholder: "Describe what should exist, happen, or become possible after successfully using the feature.",
                text: $desiredResult,
                minHeight: 120
            )
        }
    }

    private var requirementsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            AsteriumSectionHeader(title: "Requirements")
            AsteriumPickerField(title: "Would This Require Saved Data?", options: yesNoUnsureOptions, selection: $requiresSavedData)
            AsteriumPickerField(title: "Would This Need Notifications?", options: yesNoOptionalUnsureOptions, selection: $needsNotifications)
            AsteriumPickerField(title: "Would This Need Sharing?", options: yesNoOptionalUnsureOptions, selection: $needsSharing)
            AsteriumPickerField(title: "Would This Need AI?", options: yesNoOptionalUnsureOptions, selection: $needsAI)
            AsteriumTextEditor(
                title: "Additional Details",
                placeholder: "Add anything else that would help explain the request.",
                text: $additionalDetails,
                minHeight: 100
            )
        }
    }

    private var attachmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsteriumSectionHeader(title: "Reference Images")

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
                Text("Sterium will include its app version, build number, device model, iOS version, screen, and submission time.")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var submitButton: some View {
        Button {
            Task { await submitFeatureRequest() }
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
                Text(isSubmitting ? "Sending..." : "Submit Feature Request")
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
    private func submitFeatureRequest() async {
        isSubmitting = true
        submissionError = nil

        let payload = VoxiverseFeatureRequestPayload(
            featureTitle: featureTitle,
            area: area,
            featureType: featureType,
            importance: importance,
            intendedAudience: intendedAudience,
            featureDescription: featureDescription,
            imaginedWorkflow: imaginedWorkflow,
            desiredLocation: desiredLocation,
            relatedExistingFeature: relatedExistingFeature == "None" ? "" : relatedExistingFeature,
            problemAddressed: problemAddressed,
            desiredResult: desiredResult,
            requiresSavedData: requiresSavedData,
            needsNotifications: needsNotifications,
            needsSharing: needsSharing,
            needsAI: needsAI,
            additionalDetails: additionalDetails,
            attachmentData: attachmentData
        )

        do {
            let result = try await VoxiverseFeatureRequestService.shared.submit(payload)
            do {
                try saveSubmittedFeatureRequest(reportID: result.reportID, diagnostics: result.diagnostics)
                resetForm()
                dismiss()
            } catch {
                submissionError = "The feature request was sent, but its local Submitted copy could not be saved: \(error.localizedDescription)"
                isSubmitting = false
            }
        } catch {
            submissionError = error.localizedDescription
            isSubmitting = false
        }
    }

    @MainActor
    private func resetForm() {
        featureTitle = ""
        area = "General"
        featureType = "New Feature"
        importance = "Useful"
        intendedAudience = "Everyone"
        featureDescription = ""
        imaginedWorkflow = ""
        desiredLocation = "Existing Area"
        relatedExistingFeature = "None"
        problemAddressed = ""
        desiredResult = ""
        requiresSavedData = "Unsure"
        needsNotifications = "Unsure"
        needsSharing = "Unsure"
        needsAI = "Unsure"
        additionalDetails = ""
        selectedPhotos = []
        attachmentData = []
        submissionError = nil
        isSubmitting = false
    }

    @MainActor
    private func saveSubmittedFeatureRequest(reportID: String, diagnostics: SteriumReportDiagnostics) throws {
        let trimmedTitle = featureTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = featureDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedWorkflow = imaginedWorkflow.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedProblem = problemAddressed.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedResult = desiredResult.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAdditionalDetails = additionalDetails.trimmingCharacters(in: .whitespacesAndNewlines)
        let savedAttachments = attachmentData.prefix(3).enumerated().map { index, data in
            SubmittedReportAttachment(
                displayName: "Reference Image \(index + 1)",
                imageData: data
            )
        }
        let report = SubmittedReport(
            reportID: reportID,
            reportType: "Feature Request",
            title: trimmedTitle,
            descriptionText: trimmedDescription,
            expectedBehavior: "",
            steps: [],
            category: area,
            severity: "",
            frequency: "",
            featureType: featureType,
            featureImportance: importance,
            intendedAudience: intendedAudience,
            featureDescription: trimmedDescription,
            imaginedWorkflow: trimmedWorkflow,
            desiredLocation: desiredLocation,
            relatedExistingFeature: relatedExistingFeature == "None" ? "" : relatedExistingFeature,
            problemAddressed: trimmedProblem,
            desiredResult: trimmedResult,
            requiresSavedData: requiresSavedData,
            needsNotifications: needsNotifications,
            needsSharing: needsSharing,
            needsAI: needsAI,
            additionalDetails: trimmedAdditionalDetails,
            appName: diagnostics.appName,
            appVersion: diagnostics.appVersion,
            buildNumber: diagnostics.buildNumber,
            bundleIdentifier: diagnostics.bundleIdentifier,
            deviceModel: diagnostics.deviceModel,
            iOSVersion: diagnostics.iOSVersion,
            locale: diagnostics.locale,
            timeZone: diagnostics.timeZone,
            screenName: diagnostics.screenName,
            additionalNotes: trimmedAdditionalDetails,
            submittedAt: diagnostics.submittedAt,
            attachments: savedAttachments
        )
        modelContext.insert(report)
        try modelContext.save()
    }
}
