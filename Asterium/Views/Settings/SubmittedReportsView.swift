import SwiftData
import SwiftUI

struct SubmittedReportsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \SubmittedReport.submittedAt, order: .reverse) private var reports: [SubmittedReport]
    @State private var selectedReport: SubmittedReport?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                HStack(alignment: .top) {
                    AsteriumPageHeader(eyebrow: "REPORTS", title: "Submitted")
                    Spacer()
                    Button { dismiss() } label: { submittedCloseButton }
                        .buttonStyle(.plain)
                        .padding(.top, 16)
                }

                if reports.isEmpty {
                    GlassCard(cornerRadius: 22) {
                        VStack(spacing: 10) {
                            Image("inbox")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .foregroundStyle(LGradients.header)
                            Text("No submitted reports")
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundStyle(LColors.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(reports) { report in
                            Button { selectedReport = report } label: {
                                submittedReportCard(report)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, LSpacing.pageHorizontal)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
        .background { AsteriumBackground() }
        .asteriumAdaptivePresentation(isPresented: selectedReportPresented) {
            if let selectedReport {
                SubmittedReportDetailView(report: selectedReport)
            }
        }
    }

    private func submittedReportCard(_ report: SubmittedReport) -> some View {
        GlassCard(cornerRadius: 22) {
            HStack(spacing: 14) {
                Image(reportIconName(for: report))
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(LGradients.header)
                    .frame(width: 48, height: 48)
                    .background(LColors.glassSurface, in: Circle())
                    .overlay { Circle().strokeBorder(LColors.glassBorder, lineWidth: 1) }

                VStack(alignment: .leading, spacing: 5) {
                    Text(report.title)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    Text(report.submittedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)
                    Text(report.reportType)
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)
                    Text(report.reportID)
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(LGradients.header)
                }

                Spacer(minLength: 8)

                if !report.attachments.isEmpty {
                    Image("imagesign")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 17, height: 17)
                        .foregroundStyle(LGradients.header)
                }

                Image("chevright")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .foregroundStyle(LGradients.header)
            }
        }
    }

    private func reportIconName(for report: SubmittedReport) -> String {
        switch report.reportType {
        case "Beta Feedback":
            return "chatsparkle"
        case "Feature Request":
            return "brightbulb"
        default:
            return "document"
        }
    }

    private var selectedReportPresented: Binding<Bool> {
        Binding(
            get: { selectedReport != nil },
            set: { if !$0 { selectedReport = nil } }
        )
    }
}

private var submittedCloseButton: some View {
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
