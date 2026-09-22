//
//  ReportConversationView.swift
//  Sterium
//

import PhotosUI
import QuickLook
import SwiftData
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct ReportConversationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var service = SteriumReportConversationService()
    @State private var draft = ""
    @State private var showingExpandedDraft = false
    @State private var draftScrollRevision = 0
    @State private var showingPhotos = false
    @State private var showingFiles = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var attachments: [SteriumConversationAttachment] = []
    @State private var attachmentError: String?
    @State private var attachmentPreviewURL: URL?
    @State private var didPerformInitialScroll = false

    private let conversationBottomID = "sterium-conversation-bottom"

    let report: SubmittedReport

    var body: some View {
        ZStack {
            AsteriumBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    AsteriumPageHeader(eyebrow: "VOXIVERSE", title: "Private Conversation")
                    Spacer()
                    Button { dismiss() } label: { closeButton }
                        .buttonStyle(.plain)
                        .padding(.top, 16)
                }
                .padding(.horizontal, LSpacing.pageHorizontal)
                .padding(.bottom, 8)

                conversationBody
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                bottomConversationBar
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .task {
            await service.load(report: report, modelContext: modelContext, markRead: true)
        }
        .onReceive(NotificationCenter.default.publisher(
            for: SteriumReportConversationNotificationManager.conversationDataDidChange
        )) { _ in
            Task {
                await service.load(report: report, modelContext: modelContext, markRead: true)
            }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task {
                await service.load(report: report, modelContext: modelContext, markRead: true)
            }
        }
        .asteriumAdaptivePresentation(isPresented: $showingExpandedDraft) {
            ReportConversationDraftSheet(draft: $draft)
                .presentationDetents([.large])
        }
        .onChange(of: showingExpandedDraft) { _, isPresented in
            if !isPresented { draftScrollRevision += 1 }
        }
        .photosPicker(isPresented: $showingPhotos, selection: $selectedPhotos, maxSelectionCount: 3, matching: .images)
        .onChange(of: selectedPhotos) { _, items in
            Task { await loadPhotos(items) }
        }
        .fileImporter(isPresented: $showingFiles, allowedContentTypes: [.item], allowsMultipleSelection: true) { result in
            loadFiles(result)
        }
        .alert("Attachment Error", isPresented: Binding(
            get: { attachmentError != nil },
            set: { if !$0 { attachmentError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(attachmentError ?? "")
        }
        .dismissesKeyboardOnOutsideTap()
        .quickLookPreview($attachmentPreviewURL)
    }

    @ViewBuilder
    private var conversationBody: some View {
        if service.isLoading && service.snapshot == nil {
            loadingState
        } else {
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        reportContextCard
                        stateContent
                        Color.clear.frame(height: 1).id(conversationBottomID)
                    }
                    .padding(.horizontal, LSpacing.pageHorizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 18)
                }
                .onAppear {
                    scrollToConversationBottom(using: proxy, animated: false)
                }
                .onChange(of: service.displayedMessages.count) { _, _ in
                    scrollToConversationBottom(using: proxy, animated: didPerformInitialScroll)
                    didPerformInitialScroll = true
                }
                .onChange(of: service.snapshot?.acceptsReplies) { _, acceptsReplies in
                    if acceptsReplies == false {
                        scrollToConversationBottom(using: proxy, animated: true)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private var bottomConversationBar: some View {
        if bottomConversationBarIsVisible {
            composer
        }
    }

    private var bottomConversationBarIsVisible: Bool {
        guard !(service.isLoading && service.snapshot == nil) else { return false }
        return currentState != .declined
    }

    private var loadingState: some View {
        VStack(spacing: 12) {
            SteriumConversationLoadingRing()
            Text("Loading private conversation…")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(LColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func scrollToConversationBottom(using proxy: ScrollViewProxy, animated: Bool) {
        Task { @MainActor in
            await Task.yield()
            await Task.yield()
            if animated {
                withAnimation(.easeInOut(duration: 0.18)) {
                    proxy.scrollTo(conversationBottomID, anchor: .bottom)
                }
            } else {
                proxy.scrollTo(conversationBottomID, anchor: .bottom)
            }
        }
    }

    private var reportContextCard: some View {
        GlassCard(cornerRadius: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(report.reportID)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(LGradients.header)

                Text(report.title)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Private report conversation with Voxiverse.")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var stateContent: some View {
        if let error = service.errorMessage {
            errorCard(error)
        }

        switch currentState {
        case .notStarted:
            emptyState
        case .invited:
            invitationState
        case .accepted:
            messagesState
        case .declined:
            declinedState
        }
    }

    private func errorCard(_ message: String) -> some View {
        GlassCard(cornerRadius: 18) {
            Text(message)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(LColors.danger)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var emptyState: some View {
        GlassCard(cornerRadius: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Image("inbox")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(LGradients.header)
                    .accessibilityHidden(true)
                Text("No invitation yet")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                Text("If Voxiverse needs to privately discuss this report, the invitation and first message will appear here.")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var invitationState: some View {
        VStack(alignment: .center, spacing: 14) {
            GlassCard(cornerRadius: 24) {
                VStack(alignment: .center, spacing: 16) {
                    Image("chatstar")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 38, height: 38)
                        .foregroundStyle(LGradients.header)
                        .accessibilityHidden(true)

                    VStack(spacing: 8) {
                        Text("Voxiverse sent you a message")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("The Voxiverse team invited you to a private conversation about this submitted report.")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(LColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(spacing: 4) {
                        Text(report.reportID)
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .tracking(1.5)
                            .foregroundStyle(LGradients.header)
                            .multilineTextAlignment(.center)

                        Text(report.title)
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(LColors.glassBorder, lineWidth: 1)
                    }

                    Text("Accepting lets you reply in this private thread. Declining closes the invitation.")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    if service.isUpdatingInvitation {
                        ProgressView()
                            .tint(LColors.accent)
                            .accessibilityLabel("Updating invitation")
                    }

                    VStack(spacing: 10) {
                        Button {
                            Task { await service.accept(report: report, modelContext: modelContext) }
                        } label: {
                            Text("Accept")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundStyle(LColors.bg)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(LGradients.header, in: RoundedRectangle(cornerRadius: LSpacing.buttonRadius))
                        }
                        .buttonStyle(.plain)
                        .disabled(service.isUpdatingInvitation)
                        .opacity(service.isUpdatingInvitation ? 0.6 : 1)
                        .accessibilityLabel("Accept private conversation invitation")

                        Button {
                            Task { await service.decline(report: report, modelContext: modelContext) }
                        } label: {
                            Text("Decline")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundStyle(LColors.textPrimary)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: LSpacing.buttonRadius))
                                .overlay {
                                    RoundedRectangle(cornerRadius: LSpacing.buttonRadius, style: .continuous)
                                        .strokeBorder(LColors.glassBorderStrong, lineWidth: 1)
                                }
                        }
                        .buttonStyle(.plain)
                        .disabled(service.isUpdatingInvitation)
                        .opacity(service.isUpdatingInvitation ? 0.6 : 1)
                        .accessibilityLabel("Decline private conversation invitation")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }

            if let firstMessage = firstStaffMessage {
                messageBubble(firstMessage)
                    .id(firstMessage.id)
            }
        }
    }

    private var messagesState: some View {
        VStack(alignment: .leading, spacing: 12) {
            if messages.isEmpty {
                GlassCard(cornerRadius: 24) {
                    Text("No messages yet.")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                ForEach(messages) { message in
                    messageBubble(message)
                        .id(message.id)
                }
            }

            if service.snapshot?.acceptsReplies == false {
                Text("This conversation is currently read only. Voxiverse can turn replies back on at any time.")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .id("read-only-status")
            }
        }
    }

    private var declinedState: some View {
        GlassCard(cornerRadius: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Image("xmarkwavy")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(LGradients.header)
                Text("Invitation declined")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                Text("This report conversation is closed on your side. Voxiverse can see that you declined.")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func messageBubble(_ message: SteriumReportConversationMessage) -> some View {
        HStack {
            if message.isFromReporter { Spacer(minLength: 60) }

            VStack(alignment: message.isFromReporter ? .trailing : .leading, spacing: 8) {
                GlassCard(cornerRadius: 18, padding: 0) {
                    VStack(alignment: message.isFromReporter ? .trailing : .leading, spacing: 4) {
                        Text(message.isFromReporter ? "You" : "Voxiverse")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundStyle(LColors.textSecondary)

                        if !message.body.isEmpty {
                            Text(message.body)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(LColors.textPrimary)
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Text(message.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
                            .foregroundStyle(LColors.textSecondary)

                        if message.isFromReporter && message.deliveryState != .sent {
                            HStack(spacing: 8) {
                                Text(message.deliveryState == .sending ? "Sending…" : "Failed to send")
                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                                    .foregroundStyle(message.deliveryState == .failed ? LColors.danger : LColors.textSecondary)
                                if message.deliveryState == .failed {
                                    Button("Retry") {
                                        service.retryReporterMessage(message.id, report: report, modelContext: modelContext)
                                    }
                                    .font(.system(size: 9, weight: .black, design: .rounded))
                                    .foregroundStyle(LGradients.header)
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                }

                ForEach(message.attachments) { attachment in
                    Button {
                        openAttachment(attachment)
                    } label: {
                        attachmentLabel(attachment)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open \(attachment.name)")
                }
            }

            if !message.isFromReporter { Spacer(minLength: 60) }
        }
    }


    @ViewBuilder
    private func attachmentLabel(_ attachment: SteriumConversationAttachment) -> some View {
        if UTType(attachment.typeIdentifier)?.conforms(to: .image) == true,
           let image = UIImage(data: attachment.data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 180, height: 120, alignment: .top)
                .background(LColors.glassSurface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(LGradients.header, lineWidth: 2)
                }
                .shadow(color: LColors.accent.opacity(0.3), radius: 6)
        } else {
            HStack(spacing: 8) {
                Image("attach")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(LGradients.header)
                Text(attachment.name)
            }
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(LColors.textPrimary)
            .lineLimit(1)
            .padding(10)
            .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(LColors.glassBorder, lineWidth: 1)
            }
        }
    }

    private func openAttachment(_ attachment: SteriumConversationAttachment) {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let url = directory.appendingPathComponent(URL(fileURLWithPath: attachment.name).lastPathComponent)
            try attachment.data.write(to: url, options: .atomic)
            attachmentPreviewURL = url
        } catch {
            service.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Composer

    private var composer: some View {
        VStack(spacing: 8) {
            if let error = service.errorMessage {
                Text(error)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(LColors.danger)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            GlassCard(cornerRadius: 22, padding: 12) {
                VStack(spacing: 8) {
                    HStack(alignment: .top, spacing: 8) {
                        ZStack(alignment: .topLeading) {
                            CompactReportDraftEditor(
                                text: $draft,
                                scrollToEndRevision: draftScrollRevision,
                                isEnabled: canSendMessages
                            )
                            .frame(height: 56)

                            if draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text(canSendMessages ? "Reply to Voxiverse…" : currentState == .accepted
                                     ? "Replies are currently turned off."
                                     : currentState == .invited
                                     ? "Accept the invitation to reply."
                                     : "Waiting for Voxiverse to send the first message…")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundStyle(LColors.textSecondary)
                                    .padding(.leading, 5)
                                    .padding(.top, 10)
                                    .allowsHitTesting(false)
                            }
                        }

                        Button {
                            showingExpandedDraft = true
                        } label: {
                            Image("expand")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(LGradients.header)
                                .frame(width: 36, height: 36)
                        }
                        .buttonStyle(.plain)
                        .disabled(!canSendMessages)
                        .opacity(canSendMessages ? 1 : 0.45)
                        .accessibilityLabel("Expand message draft")
                    }
                    .frame(maxWidth: .infinity, minHeight: 62, maxHeight: 62, alignment: .top)

                    if !attachments.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(attachments) { attachment in
                                    HStack(spacing: 6) {
                                        Text(attachment.name)
                                            .lineLimit(1)
                                        Button {
                                            attachments.removeAll { $0.id == attachment.id }
                                        } label: {
                                            Image("xmarkwavy")
                                                .renderingMode(.template)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 12, height: 12)
                                                .foregroundStyle(LGradients.header)
                                        }
                                        .accessibilityLabel("Remove \(attachment.name)")
                                    }
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(LColors.textPrimary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background(LColors.glassSurface, in: Capsule())
                                }
                            }
                        }
                    }

                    Rectangle()
                        .fill(LColors.glassBorder)
                        .frame(height: 1)

                    HStack {
                        Menu {
                            Button("Gallery") { showingPhotos = true }
                            Button("Files") { showingFiles = true }
                        } label: {
                            Image("attach")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .foregroundStyle(LGradients.header)
                                .frame(width: 40, height: 40)
                        }
                        .buttonStyle(.plain)
                        .disabled(!canSendMessages)
                        .opacity(canSendMessages ? 1 : 0.45)
                        .accessibilityLabel("Add attachment")

                        Spacer(minLength: 0)

                        Button(action: sendDraft) {
                            Image("send")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .foregroundStyle(LGradients.header)
                                .frame(width: 40, height: 40)
                        }
                        .buttonStyle(.plain)
                        .disabled(!canSend)
                        .opacity(canSend ? 1 : 0.45)
                        .accessibilityLabel("Send message")
                    }
                }
            }
        }
        .padding(.horizontal, LSpacing.pageHorizontal)
        .padding(.top, 10)
        .padding(.bottom, 16)
        .background(LColors.bg.opacity(0.96))
    }

    private var closeButton: some View {
        Image("xmarkwavy")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 28, height: 28)
            .foregroundStyle(LGradients.header)
    }

    private var currentState: SteriumReportConversationState {
        service.snapshot?.state ?? report.conversationState
    }

    private var messages: [SteriumReportConversationMessage] {
        service.displayedMessages
    }

    private var firstStaffMessage: SteriumReportConversationMessage? {
        messages.first { $0.senderRole == .staff }
    }

    private var canSendMessages: Bool {
        currentState == .accepted && (service.snapshot?.acceptsReplies ?? true)
    }

    private var canSend: Bool {
        canSendMessages && (!draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !attachments.isEmpty)
    }

    private func sendDraft() {
        guard canSend else { return }
        let message = draft
        let selectedAttachments = attachments
        if service.sendReporterMessage(message, attachments: selectedAttachments, report: report, modelContext: modelContext) {
            draft = ""
            attachments = []
        }
    }

    private func addAttachment(name: String, typeIdentifier: String, data: Data) {
        guard attachments.count < 3 else {
            attachmentError = "You can attach up to three items to a message."
            return
        }
        do {
            let prepared = try ConversationImageOptimizer.prepare(data: data, name: name, typeIdentifier: typeIdentifier)
            guard prepared.data.count <= ConversationImageOptimizer.maximumAttachmentBytes else {
                attachmentError = "Files must be 10 MB or smaller."
                return
            }
            attachments.append(SteriumConversationAttachment(name: prepared.name, typeIdentifier: prepared.typeIdentifier, data: prepared.data))
        } catch {
            attachmentError = error.localizedDescription
        }
    }

    private func loadPhotos(_ items: [PhotosPickerItem]) async {
        for item in items {
            do {
                guard let data = try await item.loadTransferable(type: Data.self) else { continue }
                let type = item.supportedContentTypes.first ?? .image
                let ext = type.preferredFilenameExtension ?? "jpg"
                addAttachment(name: "Photo \(attachments.count + 1).\(ext)", typeIdentifier: type.identifier, data: data)
            } catch {
                attachmentError = error.localizedDescription
            }
        }
        selectedPhotos = []
    }

    private func loadFiles(_ result: Result<[URL], Error>) {
        do {
            for url in try result.get() {
                let access = url.startAccessingSecurityScopedResource()
                defer { if access { url.stopAccessingSecurityScopedResource() } }
                let resourceType = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType
                let extensionType = UTType(filenameExtension: url.pathExtension)
                let type = resourceType?.conforms(to: .image) == true
                    ? (resourceType ?? .image)
                    : (extensionType ?? resourceType ?? .data)
                let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                let sourceLimit = type.conforms(to: .image)
                    ? ConversationImageOptimizer.maximumSourceImageBytes
                    : ConversationImageOptimizer.maximumAttachmentBytes
                guard size <= sourceLimit else {
                    attachmentError = type.conforms(to: .image)
                        ? "This image is too large to process."
                        : "Files must be 10 MB or smaller."
                    continue
                }
                let data = try Data(contentsOf: url)
                addAttachment(name: url.lastPathComponent, typeIdentifier: type.identifier, data: data)
            }
        } catch {
            attachmentError = error.localizedDescription
        }
    }
}

private struct SteriumConversationLoadingRing: View {
    private let dotCount = 15

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                ForEach(0..<dotCount, id: \.self) { index in
                    let pulse = 0.72 + (0.28 * (cos((elapsed * 5.2) - (Double(index) * 0.48)) + 1) / 2)
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay { Circle().fill(LGradients.header).opacity(0.88) }
                        .overlay { Circle().strokeBorder(LGradients.header, lineWidth: 1) }
                        .frame(width: 13, height: 13)
                        .scaleEffect(pulse)
                        .offset(y: -39)
                        .rotationEffect(.degrees(Double(index) * (360 / Double(dotCount))))
                }
            }
            .frame(width: 96, height: 96)
            .rotationEffect(.degrees(elapsed * 42))
        }
        .frame(width: 96, height: 96)
        .accessibilityLabel("Loading private conversation")
    }
}

private struct CompactReportDraftEditor: UIViewRepresentable {
    @Binding var text: String
    let scrollToEndRevision: Int
    let isEnabled: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.delegate = context.coordinator
        view.backgroundColor = .clear
        view.isOpaque = false
        view.isScrollEnabled = true
        view.showsVerticalScrollIndicator = false
        view.textColor = UIColor(LColors.textPrimary)
        view.tintColor = UIColor(LColors.accent)
        let font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        view.font = font.fontDescriptor.withDesign(.rounded)
            .map { UIFont(descriptor: $0, size: 15) } ?? font
        view.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        view.textContainer.lineFragmentPadding = 0
        view.accessibilityLabel = "Reply to Voxiverse"
        view.text = text
        view.isEditable = isEnabled
        view.isUserInteractionEnabled = isEnabled
        return view
    }

    func updateUIView(_ view: UITextView, context: Context) {
        context.coordinator.parent = self
        view.isEditable = isEnabled
        view.isUserInteractionEnabled = isEnabled
        if !isEnabled && view.isFirstResponder { view.resignFirstResponder() }
        let textChanged = view.text != text
        let shouldScroll = context.coordinator.lastScrollRevision != scrollToEndRevision
        guard textChanged || shouldScroll else { return }

        if textChanged { view.text = text }
        context.coordinator.lastScrollRevision = scrollToEndRevision
        let end = (text as NSString).length
        view.selectedRange = NSRange(location: end, length: 0)
        DispatchQueue.main.async {
            view.layoutIfNeeded()
            view.scrollRangeToVisible(NSRange(location: end, length: 0))
        }
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: CompactReportDraftEditor
        var lastScrollRevision: Int

        init(_ parent: CompactReportDraftEditor) {
            self.parent = parent
            lastScrollRevision = parent.scrollToEndRevision
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}

private struct ReportConversationDraftSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var draft: String
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            AsteriumBackground()

            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                AsteriumPageHeader(eyebrow: "VOXIVERSE", title: "Message Draft")

                GlassCard(cornerRadius: 24, padding: 12) {
                    ZStack(alignment: .topLeading) {
                        if draft.isEmpty {
                            Text("Reply to Voxiverse…")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(LColors.textSecondary)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 8)
                                .allowsHitTesting(false)
                        }

                        TextEditor(text: $draft)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(LColors.textPrimary)
                            .tint(LColors.accent)
                            .scrollContentBackground(.hidden)
                            .focused($isFocused)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxHeight: .infinity)

                AsteriumPrimaryButton(title: "Done") {
                    dismiss()
                }
            }
            .padding(.horizontal, LSpacing.pageHorizontal)
            .padding(.bottom, 16)
        }
        .onAppear { isFocused = true }
        .dismissesKeyboardOnOutsideTap()
    }
}
