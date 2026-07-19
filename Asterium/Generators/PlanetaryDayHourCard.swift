//
//  PlanetaryDayHourCard.swift
//  Asterium
//

import SwiftUI

struct PlanetaryDayHourCard: View {
    @StateObject private var service: PlanetaryHourService

    @MainActor
    init(service: PlanetaryHourService? = nil) {
        _service = StateObject(wrappedValue: service ?? PlanetaryHourService())
    }

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                header

                switch service.state {
                case .ready:
                    if let result = service.result {
                        resultContent(result)
                    } else {
                        loadingContent
                    }

                case .idle, .requestingLocation:
                    loadingContent

                case .locationDenied:
                    unavailableContent(
                        title: "Location Needed",
                        message: "Allow location access so Asterium can calculate local sunrise, sunset, and planetary hours."
                    )

                case .unavailable(let message):
                    unavailableContent(
                        title: "Planetary Hours Unavailable",
                        message: message
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("PLANETARY TIME")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(LGradients.header)

                Text("Day & Hour")
                    .font(.system(size: 21, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
            }

            Spacer()

            Button {
                service.refresh()
            } label: {
                Text("Refresh")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(LGradients.header)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private func resultContent(_ result: PlanetaryHourResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                planetBlock(
                    label: "PLANETARY DAY",
                    planet: result.planetaryDay
                )

                planetBlock(
                    label: "CURRENT HOUR",
                    planet: result.currentPlanet
                )
            }

            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text(
                        "\(result.period.displayName) Hour \(result.periodHourNumber)"
                    )
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)

                    Spacer()

                    Text(
                        "\(timeString(result.startTime)) – \(timeString(result.endTime))"
                    )
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                }

                ProgressView(value: progress(for: result))
                    .tint(LColors.textPrimary)
            }

            Text(result.currentPlanet.keywords)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(LColors.textSecondary)

            HStack {
                Text("Next: \(result.nextPlanet.displayName)")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)

                Spacer()

                Text(relativeTime(to: result.nextChangeTime))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(LGradients.header)
            }

            Divider()
                .opacity(0.18)

            HStack {
                solarTime(label: "Sunrise", date: result.sunrise)

                Spacer()

                solarTime(label: "Sunset", date: result.sunset)
            }
        }
    }

    private func planetBlock(
        label: String,
        planet: Planet
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textSecondary)

            HStack(spacing: 7) {
                Text(planet.symbol)
                    .font(.system(size: 22, weight: .bold))

                Text(planet.displayName)
                    .font(.system(size: 17, weight: .black, design: .rounded))
            }
            .foregroundStyle(LColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func solarTime(
        label: String,
        date: Date
    ) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textSecondary)

            Text(timeString(date))
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textPrimary)
        }
    }

    private var loadingContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            ProgressView()

            Text("Calculating local planetary time…")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(LColors.textSecondary)
        }
    }

    private func unavailableContent(
        title: String,
        message: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(LColors.textPrimary)

            Text(message)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(LColors.textSecondary)
        }
    }

    private func progress(for result: PlanetaryHourResult) -> Double {
        let duration = result.endTime.timeIntervalSince(result.startTime)
        guard duration > 0 else { return 0 }

        let elapsed = Date().timeIntervalSince(result.startTime)
        return min(max(elapsed / duration, 0), 1)
    }

    private func timeString(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }

    private func relativeTime(to date: Date) -> String {
        let remaining = max(Int(date.timeIntervalSinceNow), 0)
        let minutes = remaining / 60
        let seconds = remaining % 60

        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }

        return "\(seconds)s"
    }
}
