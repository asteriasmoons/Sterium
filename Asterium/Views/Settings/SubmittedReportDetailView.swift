import SwiftUI

struct SubmittedReportDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let report: SubmittedReport
    @State private var selectedAttachment: SubmittedReportAttachment?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private let attachmentColumns = [
        GridItem(.adaptive(minimum: 112, maximum: 112), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                HStack(alignment: .top) {
                    AsteriumPageHeader(eyebrow: report.reportType, title: report.title)
                    Spacer()
                    Button { dismiss() } label: { reportDetailCloseButton }
                        .buttonStyle(.plain)
                        .padding(.top, 16)
                }

                reportDetails
                attachmentsSection
            }
            .padding(.horizontal, LSpacing.pageHorizontal)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background { AsteriumBackground() }
        .asteriumAdaptivePresentation(isPresented: selectedAttachmentPresented) {
            if let selectedAttachment {
                SubmittedReportImageView(attachment: selectedAttachment)
            }
        }
    }

    @ViewBuilder
    private var reportDetails: some View {
        if report.reportType == "Feature Request" {
            featureRequestDetails
        } else if report.reportType == "Beta Feedback" {
            betaFeedbackDetails
        } else {
            bugReportDetails
        }
    }

    private var featureRequestDetails: some View {
        VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
            LazyVGrid(columns: columns, spacing: 12) {
                metadataTile(label: "Submitted", value: report.submittedAt.formatted(date: .abbreviated, time: .omitted))
                metadataTile(label: "Report ID", value: report.reportID)
                metadataTile(label: "Area", value: report.category)
                metadataTile(label: "Feature Type", value: report.featureType)
                metadataTile(label: "Importance", value: report.featureImportance)
                metadataTile(label: "Who Is This For?", value: report.intendedAudience)
                metadataTile(label: "Where Should It Live?", value: report.desiredLocation)
                metadataTile(label: "Saved Data", value: report.requiresSavedData)
                metadataTile(label: "Notifications", value: report.needsNotifications)
                metadataTile(label: "Sharing", value: report.needsSharing)
                metadataTile(label: "AI", value: report.needsAI)
            }

            reportTextSection(title: "What Should the Feature Do?", text: report.featureDescription)
            reportTextSection(title: "How Should It Work?", text: report.imaginedWorkflow)

            if !report.relatedExistingFeature.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                reportTextSection(title: "Related Existing Feature", text: report.relatedExistingFeature)
            }

            reportTextSection(title: "Problem or Limitation", text: report.problemAddressed)
            reportTextSection(title: "Desired Result", text: report.desiredResult)

            if !report.additionalDetails.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                reportTextSection(title: "Additional Details", text: report.additionalDetails)
            }

            diagnosticsSection
        }
    }

    private var betaFeedbackDetails: some View {
        VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
            LazyVGrid(columns: columns, spacing: 12) {
                metadataTile(label: "Submitted", value: report.submittedAt.formatted(date: .abbreviated, time: .omitted))
                metadataTile(label: "Report Type", value: report.reportType)
                metadataTile(label: "Area", value: report.category)
                metadataTile(label: "Experience", value: report.overallExperience)
                metadataTile(label: "Report ID", value: report.reportID)
            }

            reportTextSection(title: "What Did You Test?", text: report.testedWhat)
            reportTextSection(title: "What Worked Well?", text: report.workedWell)
            reportTextSection(title: "What Could Be Better?", text: report.couldBeBetter)
            reportTextSection(title: "Anything Unexpected?", text: report.unexpected)
            reportTextSection(title: "Additional Thoughts", text: report.additionalNotes)
            diagnosticsSection
        }
    }

    private var bugReportDetails: some View {
        VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                LazyVGrid(columns: columns, spacing: 12) {
                    metadataTile(label: "Submitted", value: report.submittedAt.formatted(date: .abbreviated, time: .omitted))
                    metadataTile(label: "Status", value: report.status)
                    metadataTile(label: "Area", value: report.category)
                    metadataTile(label: "Severity", value: report.severity)
                    metadataTile(label: "Frequency", value: report.frequency)
                    metadataTile(label: "Report ID", value: report.reportID)
                }

                reportTextSection(title: "What Happened", text: report.descriptionText)
                reportTextSection(title: "Expected Behavior", text: report.expectedBehavior)

                if !report.steps.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        AsteriumSectionHeader(title: "Steps to Reproduce")
                        GlassCard(cornerRadius: 22) {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(report.steps.indices, id: \.self) { index in
                                    HStack(alignment: .center, spacing: 12) {
                                        Text("\(index + 1)")
                                            .font(.system(size: 13, weight: .black, design: .rounded))
                                            .foregroundStyle(LColors.bg)
                                            .frame(width: 28, height: 28)
                                            .background(LGradients.tag, in: Circle())
                                        Text(report.steps[index])
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundStyle(LColors.textPrimary)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Spacer(minLength: 0)
                                    }
                                }
                            }
                        }
                    }
                }

                reportTextSection(title: "Additional Notes", text: report.additionalNotes)
        }
    }

    @ViewBuilder
    private var attachmentsSection: some View {
        if !report.attachments.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                AsteriumSectionHeader(title: report.reportType == "Feature Request" ? "Reference Images" : "Attachments")
                LazyVGrid(columns: attachmentColumns, spacing: 12) {
                    ForEach(report.attachments.sorted { $0.createdAt < $1.createdAt }) { attachment in
                        Button { selectedAttachment = attachment } label: {
                            SubmittedReportAttachmentCard(attachment: attachment)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    private var diagnosticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsteriumSectionHeader(title: "Diagnostics")
            LazyVGrid(columns: columns, spacing: 12) {
                metadataTile(label: "App", value: report.appName)
                metadataTile(label: "Version", value: report.appVersion)
                metadataTile(label: "Build", value: report.buildNumber)
                metadataTile(label: "Device", value: report.deviceModel)
                metadataTile(label: "iOS", value: report.iOSVersion)
                metadataTile(label: "Screen", value: displayScreenName)
            }
        }
    }

    private var displayScreenName: String {
        let trimmed = report.screenName.trimmingCharacters(in: .whitespacesAndNewlines)
        if let last = trimmed.split(separator: ">", omittingEmptySubsequences: true).last {
            return String(last).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return trimmed
    }

    private func metadataTile(label: String, value: String) -> some View {
        GlassCard(cornerRadius: 18, padding: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(LColors.textSecondary)
                Text(value.isEmpty ? "Not provided" : value)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(value.isEmpty ? AnyShapeStyle(LColors.textSecondary) : AnyShapeStyle(LColors.textPrimary))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }

    private func reportTextSection(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            AsteriumSectionHeader(title: title)
            GlassCard(cornerRadius: 22) {
                Text(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Not provided" : text)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? LColors.textSecondary : LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var selectedAttachmentPresented: Binding<Bool> {
        Binding(
            get: { selectedAttachment != nil },
            set: { if !$0 { selectedAttachment = nil } }
        )
    }
}

private struct SubmittedReportAttachmentCard: View {
    let attachment: SubmittedReportAttachment

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.10))

                if let image = UIImage(data: attachment.imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 96, height: 96)
                        .clipped()
                } else {
                    Image("imagesign")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(LColors.textSecondary)
                }
            }
            .frame(width: 96, height: 96)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(LColors.glassBorder, lineWidth: 1)
            }

            Text(attachment.displayName)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(LColors.textSecondary)
                .lineLimit(1)
                .frame(width: 96, alignment: .center)
        }
        .padding(8)
        .frame(width: 112, height: 132)
        .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(LColors.glassBorder, lineWidth: 1)
        }
    }
}

private var reportDetailCloseButton: some View {
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
