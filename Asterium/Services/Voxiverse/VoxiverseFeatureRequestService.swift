//
//  VoxiverseFeatureRequestService.swift
//  Sterium
//

import CloudKit
import Foundation

struct VoxiverseFeatureRequestPayload {
    let featureTitle: String
    let area: String
    let featureType: String
    let importance: String
    let intendedAudience: String
    let featureDescription: String
    let imaginedWorkflow: String
    let desiredLocation: String
    let relatedExistingFeature: String
    let problemAddressed: String
    let desiredResult: String
    let requiresSavedData: String
    let needsNotifications: String
    let needsSharing: String
    let needsAI: String
    let additionalDetails: String
    let attachmentData: [Data]
}

enum VoxiverseFeatureRequestError: LocalizedError {
    case missingRequiredFields

    var errorDescription: String? {
        switch self {
        case .missingRequiredFields:
            return "Please complete the required fields before submitting."
        }
    }
}

final class VoxiverseFeatureRequestService {
    static let shared = VoxiverseFeatureRequestService()

    private let container: CKContainer
    private let database: CKDatabase

    private init() {
        container = CKContainer(identifier: VoxiverseBugReportService.containerIdentifier)
        database = container.publicCloudDatabase
    }

    @MainActor
    func submit(_ payload: VoxiverseFeatureRequestPayload) async throws -> (reportID: String, diagnostics: SteriumReportDiagnostics) {
        let trimmedTitle = payload.featureTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedArea = payload.area.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedFeatureType = payload.featureType.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedImportance = payload.importance.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAudience = payload.intendedAudience.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = payload.featureDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedWorkflow = payload.imaginedWorkflow.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLocation = payload.desiredLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedProblem = payload.problemAddressed.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedResult = payload.desiredResult.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSavedData = payload.requiresSavedData.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotifications = payload.needsNotifications.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSharing = payload.needsSharing.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAI = payload.needsAI.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty,
              !trimmedArea.isEmpty,
              !trimmedFeatureType.isEmpty,
              !trimmedImportance.isEmpty,
              !trimmedAudience.isEmpty,
              !trimmedDescription.isEmpty,
              !trimmedWorkflow.isEmpty,
              !trimmedLocation.isEmpty,
              !trimmedProblem.isEmpty,
              !trimmedResult.isEmpty,
              !trimmedSavedData.isEmpty,
              !trimmedNotifications.isEmpty,
              !trimmedSharing.isEmpty,
              !trimmedAI.isEmpty else {
            throw VoxiverseFeatureRequestError.missingRequiredFields
        }

        let diagnostics = SteriumReportDiagnostics.current(screenName: "Feature Request")
        let reportID = "STR-\(UUID().uuidString.prefix(8).uppercased())"
        let submittedAt = diagnostics.submittedAt
        let recordID = CKRecord.ID(recordName: reportID)
        let record = CKRecord(recordType: "Report", recordID: recordID)
        record["reportID"] = reportID as CKRecordValue
        record["requestID"] = reportID as CKRecordValue
        record["appID"] = (diagnostics.bundleIdentifier.isEmpty ? "im.lystaria.Asterium" : diagnostics.bundleIdentifier) as CKRecordValue
        record["appName"] = diagnostics.appName as CKRecordValue
        record["reportType"] = "Feature Request" as CKRecordValue
        record["title"] = trimmedTitle as CKRecordValue
        record["category"] = trimmedArea as CKRecordValue
        record["status"] = "New" as CKRecordValue
        record["submittedAt"] = submittedAt as CKRecordValue
        record["createdAt"] = submittedAt as CKRecordValue
        record["updatedAt"] = submittedAt as CKRecordValue
        record["requestCount"] = 1 as CKRecordValue
        record["descriptionText"] = trimmedDescription as CKRecordValue
        record["featureType"] = trimmedFeatureType as CKRecordValue
        record["importance"] = trimmedImportance as CKRecordValue
        record["intendedAudience"] = trimmedAudience as CKRecordValue
        record["featureDescription"] = trimmedDescription as CKRecordValue
        record["imaginedWorkflow"] = trimmedWorkflow as CKRecordValue
        record["desiredLocation"] = trimmedLocation as CKRecordValue
        record["relatedExistingFeature"] = payload.relatedExistingFeature.trimmingCharacters(in: .whitespacesAndNewlines) as CKRecordValue
        record["problemAddressed"] = trimmedProblem as CKRecordValue
        record["desiredResult"] = trimmedResult as CKRecordValue
        record["requiresSavedData"] = trimmedSavedData as CKRecordValue
        record["needsNotifications"] = trimmedNotifications as CKRecordValue
        record["needsSharing"] = trimmedSharing as CKRecordValue
        record["needsAI"] = trimmedAI as CKRecordValue
        record["additionalDetails"] = payload.additionalDetails.trimmingCharacters(in: .whitespacesAndNewlines) as CKRecordValue
        record["internalNotes"] = payload.additionalDetails.trimmingCharacters(in: .whitespacesAndNewlines) as CKRecordValue
        record["deviceModel"] = diagnostics.deviceModel as CKRecordValue
        record["iOSVersion"] = diagnostics.iOSVersion as CKRecordValue
        record["appVersion"] = diagnostics.appVersion as CKRecordValue
        record["buildNumber"] = diagnostics.buildNumber as CKRecordValue
        record["screenName"] = diagnostics.screenName as CKRecordValue

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
            .appendingPathComponent("VoxiverseFeatureRequests", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        return try dataItems.prefix(3).enumerated().map { index, data in
            let url = directory.appendingPathComponent("\(reportID)-\(index + 1).jpg")
            try data.write(to: url, options: .atomic)
            return url
        }
    }
}
