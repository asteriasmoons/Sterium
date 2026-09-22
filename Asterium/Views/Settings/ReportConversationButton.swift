//
//  ReportConversationButton.swift
//  Sterium
//

import SwiftUI

struct ReportConversationButton: View {
    let state: SteriumReportConversationState
    let unreadCount: Int
    let action: () -> Void

    private var title: String {
        switch state {
        case .notStarted:
            return "Private Conversation"
        case .invited:
            return "Voxiverse Sent You a Message"
        case .accepted:
            return unreadCount > 0 ? "New Message from Voxiverse" : "Conversation with Voxiverse"
        case .declined:
            return "Conversation Declined"
        }
    }

    private var subtitle: String {
        switch state {
        case .notStarted:
            return "If Voxiverse needs details, the message will appear here."
        case .invited:
            return "Review the invitation for this report."
        case .accepted:
            return unreadCount > 0 ? "\(unreadCount) unread" : "Open your private report thread."
        case .declined:
            return "You declined this private report conversation."
        }
    }

    private var showsBadge: Bool {
        state == .invited || unreadCount > 0
    }

    var body: some View {
        Button(action: action) {
            GlassCard(cornerRadius: 24) {
                HStack(spacing: 14) {
                    ZStack(alignment: .topTrailing) {
                        Image("chatstar")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(LGradients.header)
                            .frame(width: 54, height: 54)
                            .background(LColors.glassSurface, in: Circle())
                            .overlay {
                                if showsBadge {
                                    Circle()
                                        .trim(from: 0.08, to: 0.92)
                                        .stroke(LGradients.header, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                                        .rotationEffect(.degrees(-45))
                                } else {
                                    Circle().strokeBorder(LGradients.header, lineWidth: 1.5)
                                }
                            }

                        if showsBadge {
                            Circle()
                                .fill(LGradients.header)
                                .frame(width: 16, height: 16)
                                .accessibilityHidden(true)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 17, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(subtitle)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(LColors.textSecondary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 8)

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
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint(subtitle)
    }
}
