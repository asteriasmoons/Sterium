import SwiftUI

struct ReportCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingBugReport = false
    @State private var showingBetaFeedback = false
    @State private var showingFeatureRequest = false
    @State private var showingSubmitted = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                HStack(alignment: .top) {
                    AsteriumPageHeader(eyebrow: "VOXIVERSE", title: "Send a Report")
                    Spacer()
                    Button { dismiss() } label: { closeButton }
                        .buttonStyle(.plain)
                        .padding(.top, 16)
                }

                Button { showingBugReport = true } label: {
                    reportCard(
                        title: "Bug Report",
                        subtitle: "Tell Voxiverse what went wrong.",
                        asset: "bug"
                    )
                }
                .buttonStyle(.plain)

                Button { showingBetaFeedback = true } label: {
                    reportCard(
                        title: "Beta Feedback",
                        subtitle: "Share what you tested and how it felt.",
                        asset: "chatsparkle"
                    )
                }
                .buttonStyle(.plain)

                Button { showingFeatureRequest = true } label: {
                    reportCard(
                        title: "Feature Request",
                        subtitle: "Request something new for Sterium.",
                        asset: "brightbulb"
                    )
                }
                .buttonStyle(.plain)

                Button { showingSubmitted = true } label: {
                    reportCard(
                        title: "Submitted",
                        subtitle: "View reports sent from this device.",
                        asset: "inbox"
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, LSpacing.pageHorizontal)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
        .background { AsteriumBackground() }
        .asteriumAdaptivePresentation(isPresented: $showingBugReport) {
            BugReportView()
        }
        .asteriumAdaptivePresentation(isPresented: $showingBetaFeedback) {
            BetaFeedbackView()
        }
        .asteriumAdaptivePresentation(isPresented: $showingFeatureRequest) {
            FeatureRequestView()
        }
        .asteriumAdaptivePresentation(isPresented: $showingSubmitted) {
            SubmittedReportsView()
        }
    }

    private func reportCard(
        title: String,
        subtitle: String,
        asset: String,
        isPlaceholder: Bool = false
    ) -> some View {
        GlassCard(cornerRadius: 24) {
            HStack(spacing: 14) {
                Image(asset)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(isPlaceholder ? AnyShapeStyle(LColors.textSecondary) : AnyShapeStyle(LGradients.header))
                    .frame(width: 54, height: 54)
                    .background(LColors.glassSurface, in: Circle())
                    .overlay { Circle().strokeBorder(LColors.glassBorder, lineWidth: 1) }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(isPlaceholder ? LColors.textSecondary : LColors.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)
                }

                Spacer()

                if !isPlaceholder {
                    Image("chevright")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(LGradients.header)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var closeButton: some View {
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
}
