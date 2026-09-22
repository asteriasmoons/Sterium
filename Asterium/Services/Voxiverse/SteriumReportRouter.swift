//
//  SteriumReportRouter.swift
//  Sterium
//

import Combine
import Foundation

@MainActor
final class SteriumReportRouter: ObservableObject {
    @Published private(set) var pendingReportConversationID: String?

    func handleReportConversationURL(_ url: URL) {
        let scheme = url.scheme?.lowercased()
        guard scheme == "sterium" || scheme == "asterium" else { return }
        let host = url.host?.lowercased()
        let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")).lowercased()
        guard host == "report-conversation" || path == "report-conversation" else { return }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let reportID = components?.queryItems?.first(where: { $0.name == "reportID" || $0.name == "reportId" })?.value
        if let reportID, !reportID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            handleReportConversationID(reportID)
        }
    }

    func handleReportConversationID(_ reportID: String) {
        let trimmed = reportID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        pendingReportConversationID = trimmed
    }

    func consumePendingReportConversationID() -> String? {
        let value = pendingReportConversationID
        pendingReportConversationID = nil
        return value
    }
}
