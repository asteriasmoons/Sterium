//
//  VoxiverseBugReportService.swift
//  Sterium
//

import CloudKit
import Foundation
import UIKit

struct VoxiverseBugReportPayload {
    let title: String
    let description: String
    let expectedBehavior: String
    let steps: [String]
    let category: String
    let severity: String
    let frequency: String
    let additionalNotes: String
    let attachmentData: [Data]
}

enum VoxiverseBugReportError: LocalizedError {
    case missingRequiredFields

    var errorDescription: String? {
        switch self {
        case .missingRequiredFields:
            return "Please complete the required fields before submitting."
        }
    }
}
final class VoxiverseBugReportService {
    static let shared = VoxiverseBugReportService()

    static let containerIdentifier = "iCloud.im.lystaria.Voxiverse"
    static let sourceAppName = "Sterium"

    private let container: CKContainer
    private let database: CKDatabase

    private init() {
        container = CKContainer(identifier: Self.containerIdentifier)
        database = container.publicCloudDatabase
    }

    @MainActor
    func submit(_ payload: VoxiverseBugReportPayload) async throws -> String {
        let trimmedTitle = payload.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = payload.description.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedSteps = payload.steps
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !trimmedTitle.isEmpty, !trimmedDescription.isEmpty, !cleanedSteps.isEmpty else {
            throw VoxiverseBugReportError.missingRequiredFields
        }

        let reportID = "STR-\(UUID().uuidString.prefix(8).uppercased())"
        let recordID = CKRecord.ID(recordName: reportID)
        let record = CKRecord(recordType: "Report", recordID: recordID)
        record["reportID"] = reportID as CKRecordValue
        record["appID"] = (Bundle.main.bundleIdentifier ?? "im.lystaria.Asterium") as CKRecordValue
        record["appName"] = Self.sourceAppName as CKRecordValue
        record["reportType"] = "Bug Report" as CKRecordValue
        record["title"] = trimmedTitle as CKRecordValue
        record["descriptionText"] = trimmedDescription as CKRecordValue
        record["expectedBehavior"] = payload.expectedBehavior as CKRecordValue
        record["stepsToReproduce"] = cleanedSteps.joined(separator: "\n") as CKRecordValue
        record["category"] = payload.category as CKRecordValue
        record["priority"] = payload.severity as CKRecordValue
        record["frequency"] = payload.frequency as CKRecordValue
        record["status"] = "New" as CKRecordValue
        record["internalNotes"] = payload.additionalNotes as CKRecordValue
        record["submittedAt"] = Date() as CKRecordValue
        record["deviceModel"] = Self.deviceModel as CKRecordValue
        record["iOSVersion"] = UIDevice.current.systemVersion as CKRecordValue
        record["appVersion"] = Self.appVersion as CKRecordValue
        record["buildNumber"] = Self.buildNumber as CKRecordValue
        record["bundleIdentifier"] = (Bundle.main.bundleIdentifier ?? "") as CKRecordValue
        record["screenName"] = "Settings > Bug Report" as CKRecordValue
        record["locale"] = Locale.current.identifier as CKRecordValue
        record["timeZone"] = TimeZone.current.identifier as CKRecordValue

        let tempURLs = try makeAttachmentFiles(from: payload.attachmentData, reportID: reportID)
        defer { tempURLs.forEach { try? FileManager.default.removeItem(at: $0) } }

        for (index, url) in tempURLs.enumerated() {
            record["attachment\(index + 1)"] = CKAsset(fileURL: url)
        }

        _ = try await database.save(record)
        try await addToInbox(recordName: recordID.recordName)
        return reportID
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
            .appendingPathComponent("VoxiverseBugReports", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        return try dataItems.prefix(3).enumerated().map { index, data in
            let url = directory.appendingPathComponent("\(reportID)-\(index + 1).jpg")
            try data.write(to: url, options: .atomic)
            return url
        }
    }

    private static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }

    private static var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    }

    private static var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        return mirror.children.reduce(into: "") { result, element in
            guard let value = element.value as? Int8, value != 0 else { return }
            result.append(Character(UnicodeScalar(UInt8(value))))
        }
    }
}
