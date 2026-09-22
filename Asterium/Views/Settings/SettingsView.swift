//
//  SettingsView.swift
//  Sterium
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var reportRouter: SteriumReportRouter
    @State private var showReleaseNotes = false
    @State private var showReportCenter = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                AsteriumPageHeader(eyebrow: "STERIUM", title: "Settings")

                Button {
                    showReportCenter = true
                } label: {
                    bugReportCard
                }
                .buttonStyle(.plain)

                Button {
                    showReleaseNotes = true
                } label: {
                    releaseNotesCard
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, LSpacing.pageHorizontal)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background { AsteriumBackground() }
        .asteriumAdaptivePresentation(isPresented: $showReleaseNotes) {
            ReleaseNotesView()
        }
        .asteriumAdaptivePresentation(isPresented: $showReportCenter) {
            ReportCenterView()
                .environmentObject(reportRouter)
        }
        .onAppear {
            if reportRouter.pendingReportConversationID != nil {
                showReportCenter = true
            }
        }
        .onChange(of: reportRouter.pendingReportConversationID) { _, newValue in
            if newValue != nil {
                showReportCenter = true
            }
        }
    }

    private var bugReportCard: some View {
        GlassCard(cornerRadius: 24) {
            HStack(spacing: 14) {
                Image("document")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(LGradients.header)
                    .frame(width: 54, height: 54)
                    .background(LColors.glassSurface, in: Circle())
                    .overlay { Circle().strokeBorder(LGradients.header, lineWidth: 1.5) }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Send a Report")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)
                    Text("Send feedback or review submitted reports.")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)
                }

                Spacer()
                Image("chevright")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(LGradients.header)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var releaseNotesCard: some View {
        GlassCard(cornerRadius: 24) {
            HStack(spacing: 14) {
                Image("timebook")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(LGradients.header)
                    .frame(width: 54, height: 54)
                    .background(LColors.glassSurface, in: Circle())
                    .overlay {
                        Circle().strokeBorder(LGradients.header, lineWidth: 1.5)
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Release Notes")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(LColors.textPrimary)

                    Text("See what's new in every update.")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)
                }

                Spacer()

                Image("chevright")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(LGradients.header)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
