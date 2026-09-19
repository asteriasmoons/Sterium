//
//  WorkingTimingCard.swift
//  Sterium
//
//  Compact homepage card for the Working Timing Finder. Its single control
//  cycles: Find Timing button -> inline text field -> View Timing Details.
//  It never shows the entered intention, the calculated date/time, moon info,
//  or a preview — those live only in the detail sheet.
//

import SwiftUI
import Combine
import CoreLocation

@MainActor
final class WorkingTimingViewModel: ObservableObject {
    enum Phase: Equatable {
        case idle
        case input
        case loading
        case ready
        case error(String)
    }

    @Published var phase: Phase = .idle
    @Published var intention: String = ""
    @Published private(set) var result: WorkingTimingResult?

    private let service = WorkingTimingService()

    func beginInput() {
        intention = ""
        phase = .input
    }

    func cancelInput() {
        phase = result == nil ? .idle : .ready
    }

    func submit(latitude: Double?, longitude: Double?) {
        let trimmed = intention.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return }   // empty intention: ignore

        phase = .loading

        Task {
            do {
                let profile = try await service.fetch(intention: trimmed)
                let found = await Task.detached(priority: .userInitiated) {
                    WorkingTimingFinder().find(profile: profile, latitude: latitude, longitude: longitude)
                }.value

                if var found {
                    found.userIntention = trimmed
                    self.result = found
                    self.phase = .ready
                } else {
                    self.result = nil
                    self.phase = .error("No strong timing found in the next 14 days.")
                }
            } catch {
                self.phase = .error(self.message(for: error))
            }
        }
    }

    private func message(for error: Error) -> String {
        if error is URLError {
            return "Couldn't reach the timing service. Check your connection and try again."
        }
        return (error as? LocalizedError)?.errorDescription ?? "Something went wrong. Please try again."
    }
}

struct WorkingTimingCard: View {
    let coordinate: CLLocationCoordinate2D?
    @Binding var isFieldActive: Bool

    @StateObject private var model = WorkingTimingViewModel()
    @FocusState private var fieldFocused: Bool
    @State private var showDetails = false

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                header
                control
                savedTimingsLink
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .asteriumAdaptivePresentation(isPresented: $showDetails) {
            if let result = model.result {
                WorkingTimingDetailView(result: result)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image("goalsparkle")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(LGradients.header)

            VStack(alignment: .leading, spacing: 3) {
                Text("FIND YOUR")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(LGradients.header)
                Text("Working Timing Finder")
                    .font(.system(size: 21, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }

    @ViewBuilder
    private var control: some View {
        switch model.phase {
        case .idle:
            findButton

        case .error(let message):
            VStack(alignment: .leading, spacing: 10) {
                Text(message)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                findButton
            }

        case .input:
            inputField

        case .loading:
            HStack(spacing: 10) {
                ProgressView().tint(LColors.textPrimary)
                Text("Finding your timing…")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
            }
            .frame(maxWidth: .infinity, minHeight: 26, alignment: .leading)

        case .ready:
            AsteriumPrimaryButton(title: "View Timing Details", asset: "rightwavy") {
                showDetails = true
            }
        }
    }

    private var savedTimingsLink: some View {
        NavigationLink {
            SavedTimingsView()
        } label: {
            HStack(spacing: 10) {
                Image("bookmark")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 17, height: 17)
                    .foregroundStyle(LGradients.header)
                Text("Saved Timings")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(LGradients.header)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: LSpacing.buttonRadius))
            .overlay {
                RoundedRectangle(cornerRadius: LSpacing.buttonRadius)
                    .strokeBorder(LColors.glassBorder, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var findButton: some View {
        AsteriumPrimaryButton(title: "Find Timing", asset: "goalsparkle") {
            model.beginInput()
            fieldFocused = true
        }
    }

    private var inputField: some View {
        TextField("Protection for my home", text: $model.intention)
            .focused($fieldFocused)
            .textInputAutocapitalization(.sentences)
            .autocorrectionDisabled(false)
            .submitLabel(.go)
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(LColors.textPrimary)
            .tint(LColors.accent)
            .padding(14)
            .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: LSpacing.inputRadius))
            .overlay {
                RoundedRectangle(cornerRadius: LSpacing.inputRadius)
                    .strokeBorder(LColors.glassBorder, lineWidth: 1)
            }
            .onSubmit {
                fieldFocused = false
                model.submit(latitude: coordinate?.latitude, longitude: coordinate?.longitude)
            }
            .onAppear { fieldFocused = true }
            .onChange(of: fieldFocused) { _, focused in
                isFieldActive = focused
            }
    }
}
