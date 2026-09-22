import SwiftData
import SwiftUI

struct SubmittedReportsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var reportRouter: SteriumReportRouter
    @Query(sort: \SubmittedReport.submittedAt, order: .reverse) private var reports: [SubmittedReport]
    @State private var selectedReport: SubmittedReport?
    @State private var shouldOpenConversationForSelectedReport = false
    @State private var isRefreshingConversations = false
    private let reportColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

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
                    LazyVGrid(columns: reportColumns, spacing: 12) {
                        ForEach(reports) { report in
                            Button {
                                shouldOpenConversationForSelectedReport = false
                                selectedReport = report
                            } label: {
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
                SubmittedReportDetailView(
                    report: selectedReport,
                    openConversationOnAppear: shouldOpenConversationForSelectedReport
                )
                .onDisappear {
                    shouldOpenConversationForSelectedReport = false
                }
            }
        }
        .onAppear(perform: openPendingConversationTarget)
        .onChange(of: reportRouter.pendingReportConversationID) { _, _ in
            openPendingConversationTarget()
        }
        .task(id: reportRefreshKey) {
            await refreshConversationSummaries()
        }
        .onReceive(NotificationCenter.default.publisher(
            for: SteriumReportConversationNotificationManager.conversationDataDidChange
        )) { _ in
            Task { await refreshConversationSummaries() }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await refreshConversationSummaries() }
        }
    }

    private func openPendingConversationTarget() {
        guard let pendingID = reportRouter.pendingReportConversationID else { return }
        guard let report = reports.first(where: { $0.reportID == pendingID }) else { return }
        shouldOpenConversationForSelectedReport = true
        selectedReport = report
        _ = reportRouter.consumePendingReportConversationID()
    }

    private var reportRefreshKey: String {
        reports.map(\.reportID).joined(separator: "|")
    }

    private func refreshConversationSummaries() async {
        guard !isRefreshingConversations else { return }
        guard !reports.isEmpty else { return }
        isRefreshingConversations = true
        defer { isRefreshingConversations = false }

        let service = SteriumReportConversationService()
        for report in reports {
            _ = await service.fetchSummary(for: report, modelContext: modelContext)
        }
    }

    private func conversationStatusText(for report: SubmittedReport) -> String {
        switch report.conversationState {
        case .notStarted:
            return ""
        case .invited:
            return "Invite waiting"
        case .accepted:
            return report.conversationUnreadCount > 0 ? "\(report.conversationUnreadCount) unread" : "Conversation open"
        case .declined:
            return "Declined"
        }
    }

    private func submittedReportCard(_ report: SubmittedReport) -> some View {
        GlassCard(cornerRadius: 22, padding: 14) {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    Image(reportIconName(for: report))
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(LGradients.header)
                        .frame(width: 54, height: 54)
                        .background(LColors.glassSurface, in: Circle())
                        .overlay {
                            if report.conversationState == .invited || report.conversationUnreadCount > 0 {
                                Circle()
                                    .trim(from: 0.08, to: 0.92)
                                    .stroke(LGradients.header, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                                    .rotationEffect(.degrees(-45))
                            } else {
                                Circle().strokeBorder(LGradients.header, lineWidth: 1.5)
                            }
                        }

                    if report.conversationState == .invited || report.conversationUnreadCount > 0 {
                        Circle()
                            .fill(LGradients.header)
                            .frame(width: 16, height: 16)
                            .accessibilityHidden(true)
                    }
                }

                Text(report.title)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.top, 4)

                Text(report.submittedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .lineLimit(1)

                Text(report.reportType)
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .lineLimit(1)

                Text(report.reportID)
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(LGradients.header)
                    .lineLimit(1)

                if report.conversationState != .notStarted {
                    Text(conversationStatusText(for: report))
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)
                        .lineLimit(1)
                }

                HStack(spacing: 12) {
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
                        .frame(width: 17, height: 17)
                        .foregroundStyle(LGradients.header)
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
        }
    }

    private func reportIconName(for report: SubmittedReport) -> String {
        switch report.reportType {
        case "Beta Feedback":
            return "chatstar"
        case "Feature Request":
            return "brightbulb"
        case "Bug Report":
            return "bug"
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
        .frame(width: 28, height: 28)
        .foregroundStyle(LGradients.header)
}
