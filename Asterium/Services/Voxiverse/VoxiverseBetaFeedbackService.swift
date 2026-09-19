//
//  VoxiverseBetaFeedbackService.swift
//  Sterium
//

import CloudKit
import Foundation

struct VoxiverseBetaFeedbackPayload {
    let title: String
    let area: String
    let overallExperience: String
    let testedWhat: String
    let workedWell: String
    let couldBeBetter: String
    let unexpected: String
    let additionalThoughts: String
    let attachmentData: [Data]
}

enum VoxiverseBetaFeedbackError: LocalizedError {
    case missingRequiredFields

    var errorDescription: String? {
        switch self {
        case .missingRequiredFields:
            return "Please complete the required fields before submitting."
        }
    }
}

final class VoxiverseBetaFeedbackService {
    static let shared = VoxiverseBetaFeedbackService()

    private let container: CKContainer
    private let database: CKDatabase

    private init() {
        container = CKContainer(identifier: VoxiverseBugReportService.containerIdentifier)
        database = container.publicCloudDatabase
    }

    @MainActor
    func submit(_ payload: VoxiverseBetaFeedbackPayload) async throws -> (reportID: String, diagnostics: SteriumReportDiagnostics) {
        let trimmedTitle = payload.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedArea = payload.area.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedOverallExperience = payload.overallExperience.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTestedWhat = payload.testedWhat.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty,
              !trimmedArea.isEmpty,
              !trimmedOverallExperience.isEmpty,
              !trimmedTestedWhat.isEmpty else {
            throw VoxiverseBetaFeedbackError.missingRequiredFields
        }

        let diagnostics = SteriumReportDiagnostics.current(screenName: "Settings > Beta Feedback")
        let reportID = "STR-\(UUID().uuidString.prefix(8).uppercased())"
        let recordID = CKRecord.ID(recordName: reportID)
        let record = CKRecord(recordType: "Report", recordID: recordID)
        record["reportID"] = reportID as CKRecordValue
        record["appID"] = (diagnostics.bundleIdentifier.isEmpty ? "im.lystaria.Asterium" : diagnostics.bundleIdentifier) as CKRecordValue
        record["appName"] = diagnostics.appName as CKRecordValue
        record["reportType"] = "Beta Feedback" as CKRecordValue
        record["title"] = trimmedTitle as CKRecordValue
        record["descriptionText"] = trimmedTestedWhat as CKRecordValue
        record["category"] = trimmedArea as CKRecordValue
        record["overallExperience"] = trimmedOverallExperience as CKRecordValue
        record["testedWhat"] = trimmedTestedWhat as CKRecordValue
        record["workedWell"] = payload.workedWell.trimmingCharacters(in: .whitespacesAndNewlines) as CKRecordValue
        record["couldBeBetter"] = payload.couldBeBetter.trimmingCharacters(in: .whitespacesAndNewlines) as CKRecordValue
        record["anythingUnexpected"] = payload.unexpected.trimmingCharacters(in: .whitespacesAndNewlines) as CKRecordValue
        record["internalNotes"] = payload.additionalThoughts.trimmingCharacters(in: .whitespacesAndNewlines) as CKRecordValue
        record["status"] = "New" as CKRecordValue
        record["submittedAt"] = diagnostics.submittedAt as CKRecordValue
        record["deviceModel"] = diagnostics.deviceModel as CKRecordValue
        record["iOSVersion"] = diagnostics.iOSVersion as CKRecordValue
        record["appVersion"] = diagnostics.appVersion as CKRecordValue
        record["buildNumber"] = diagnostics.buildNumber as CKRecordValue
        record["bundleIdentifier"] = diagnostics.bundleIdentifier as CKRecordValue
        record["screenName"] = diagnostics.screenName as CKRecordValue
        record["locale"] = diagnostics.locale as CKRecordValue
        record["timeZone"] = diagnostics.timeZone as CKRecordValue

        let tempURLs = try makeAttachmentFiles(from: payload.attachmentData, reportID: reportID)
        defer { tempURLs.forEach { try? FileManager.default.removeItem(at: $0) } }

        for (index, url) in tempURLs.enumerated() {
            record["attachment\(index + 1)"] = CKAsset(fileURL: url)
        }

        _ = try await database.save(record)
        try await addToInbox(recordName: recordID.recordName)
        return (reportID, diagnostics)
    }

    private func addToInbox(recordName: String) async throws {
        let inboxID = CKRecord.ID(recordName: "VoxiverseReportInbox")
        let inbox: CKRecord

        do {
            inbox = try await database.record(for: inboxID)
        } catch let error as CKError where error.code == .unknownItem {
            inbox = CKRecord(recordType: "ReportInbox", recordID: inboxID)
        }

        var names = inbox["reportRecordNames"] as? [String] ?? []
        if !names.contains(recordName) {
            names.append(recordName)
            inbox["reportRecordNames"] = names as CKRecordValue
            _ = try await database.save(inbox)
        }
    }

    private func makeAttachmentFiles(from dataItems: [Data], reportID: String) throws -> [URL] {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("VoxiverseBetaFeedback", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        return try dataItems.prefix(3).enumerated().map { index, data in
            let url = directory.appendingPathComponent("\(reportID)-\(index + 1).jpg")
            try data.write(to: url, options: .atomic)
            return url
        }
    }
}
