//
//  HomeView.swift
//  Asterium
//

import SwiftUI

struct HomeView: View {
    @StateObject private var planetaryService = PlanetaryHourService()
    @State private var now = Date()

    private let moon = MoonPhaseCalculator.calculate()
    private let sabbat = DailySpiritualCalculator.nextSabbat()
    private let today = Date()

    private var planetaryDay: Planet {
        DailySpiritualCalculator.planetaryDay(for: today)
    }

    private var weekdayName: String {
        DailySpiritualCalculator.weekdayName(for: today)
    }

    private var correspondences: DailyCorrespondences {
        DailySpiritualCalculator.correspondences(for: planetaryDay)
    }

    private var luckyHours: [LuckyHour] {
        DailySpiritualCalculator.luckyHours(from: planetaryService.result)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                AsteriumPageHeader(eyebrow: "TODAY'S", title: "Asterium")

                currentMoonCard

                upcomingSabbatCard

                planetaryDayHourCard

                correspondencesCard

                luckyHoursCard
            }
            .padding(.horizontal, LSpacing.pageHorizontal)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background { AsteriumBackground() }
        .onReceive(
            Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        ) { date in
            now = date
        }
    }

    private var currentMoonCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                cardHeader(asset: moonAssetName, eyebrow: "CURRENT MOON", title: moon.phaseName)

                HStack(spacing: 12) {
                    metricPill(label: "ZODIAC", value: moon.signName, asset: zodiacAssetName)
                    metricPill(
                        label: "ILLUMINATION",
                        value: "\(Int(round(moon.illuminationPercent)))%",
                        asset: "percentwavy"
                    )
                }

                HStack(spacing: 12) {
                    metricPill(
                        label: "MOON DAY",
                        value: "\(moon.moonDay)",
                        asset: "numcal"
                    )
                    metricPill(
                        label: "NEXT PHASE",
                        value: "\(moon.daysUntilNextPhase)d",
                        asset: "hourglassfill"
                    )
                }

                Text(moon.energyDescription)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var upcomingSabbatCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                cardHeader(asset: "ringstarcal", eyebrow: "UPCOMING SABBAT", title: sabbat.name)

                HStack(spacing: 12) {
                    metricPill(
                        label: "COUNTDOWN",
                        value: "\(sabbat.countdown(from: today)) days",
                        asset: "hourglassfill"
                    )
                    metricPill(
                        label: "DATE",
                        value: sabbat.date.formatted(date: .abbreviated, time: .omitted),
                        asset: "dotscal"
                    )
                }

                metricPill(
                    label: "LIVE COUNTDOWN",
                    value: liveSabbatCountdown,
                    asset: "clockwavy"
                )

                Text(sabbat.description)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var planetaryDayHourCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                cardHeader(asset: planetAssetName(planetaryDay), eyebrow: "PLANETARY DAY & HOUR", title: "Today")

                HStack(spacing: 12) {
                    metricPill(label: "DAY", value: weekdayName, asset: "ringstarcal")
                    metricPill(
                        label: "PLANET",
                        value: planetaryDay.displayName,
                        asset: planetAssetName(planetaryDay)
                    )
                }

                switch planetaryService.state {
                case .ready:
                    if let result = planetaryService.result {
                        planetaryHourContent(result)
                    } else {
                        planetaryLoadingContent
                    }

                case .idle, .requestingLocation:
                    planetaryLoadingContent

                case .locationDenied:
                    planetaryUnavailableContent(
                        "Location access is needed for the current planetary hour."
                    )

                case .unavailable(let message):
                    planetaryUnavailableContent(message)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var correspondencesCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                cardHeader(asset: "wand", eyebrow: "CURRENT CORRESPONDENCES", title: "Today's energies")

                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        metricPill(
                            label: "PLANET",
                            value: correspondences.planet.displayName,
                            asset: planetAssetName(correspondences.planet)
                        )
                        metricPill(
                            label: "ELEMENT",
                            value: correspondences.element,
                            asset: elementAssetName(correspondences.element)
                        )
                    }

                    HStack(spacing: 12) {
                        metricPill(
                            label: "COLOR",
                            value: correspondences.color,
                            asset: "paintdrop"
                        )
                        metricPill(
                            label: "CRYSTAL",
                            value: correspondences.crystal,
                            asset: "crystalball"
                        )
                    }

                    metricPill(
                        label: "HERB",
                        value: correspondences.herb,
                        asset: "seedling"
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var luckyHoursCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                cardHeader(asset: "clockwavy", eyebrow: "LUCKY HOURS", title: "Best time today")

                VStack(spacing: 10) {
                    ForEach(luckyHours) { hour in
                        luckyHourRow(hour)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func planetaryHourContent(_ result: PlanetaryHourResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                metricPill(
                    label: "CURRENT HOUR",
                    value: result.currentPlanet.displayName,
                    asset: planetAssetName(result.currentPlanet)
                )
                metricPill(
                    label: "NEXT",
                    value: result.nextPlanet.displayName,
                    asset: planetAssetName(result.nextPlanet)
                )
            }

            HStack {
                Text("Next: \(result.nextPlanet.displayName) in \(minutesUntil(result.nextChangeTime)) minutes")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)

                Spacer()

                Text("\(timeString(result.startTime)) - \(timeString(result.endTime))")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
            }
        }
    }

    private var planetaryLoadingContent: some View {
        HStack(spacing: 10) {
            ProgressView()
                .tint(LColors.textPrimary)

            Text("Calculating local planetary hour...")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(LColors.textSecondary)
        }
    }

    private func planetaryUnavailableContent(_ message: String) -> some View {
        Text(message)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundStyle(LColors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func cardHeader(
        asset: String,
        eyebrow: String,
        title: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(asset)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(LGradients.header)

            VStack(alignment: .leading, spacing: 3) {
                Text(eyebrow)
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(LGradients.header)

                Text(title)
                    .font(.system(size: 21, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }

    private func metricPill(
        label: String,
        value: String,
        asset: String
    ) -> some View {
        HStack(spacing: 9) {
            Image(asset)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(LGradients.header)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)

                Text(value)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(LColors.glassBorder, lineWidth: 1)
        }
    }

    private func luckyHourRow(_ hour: LuckyHour) -> some View {
        HStack(spacing: 12) {
            Image(planetAssetName(hour.planet))
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .foregroundStyle(LGradients.header)

            VStack(alignment: .leading, spacing: 3) {
                Text(hour.purpose)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(LColors.textPrimary)

                Text(hour.planet.displayName)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(LColors.textSecondary)
            }

            Spacer()

            Text(hour.timeRangeText)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(LGradients.header)
                .multilineTextAlignment(.trailing)
        }
        .padding(12)
        .background(LColors.glassSurface, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(LColors.glassBorder, lineWidth: 1)
        }
    }

    private var moonAssetName: String {
        switch moon.phaseName {
        case "New Moon": "themoon"
        case "Full Moon": "moonstar"
        default: "moonzs"
        }
    }

    private var zodiacAssetName: String {
        moon.signName.lowercased()
    }

    private func planetAssetName(_ planet: Planet) -> String {
        switch planet {
        case .sun: "thesun"
        case .moon: "themoon"
        default: planet.rawValue
        }
    }

    private func elementAssetName(_ element: String) -> String {
        switch element {
        case "Fire": "fire"
        case "Water": "water"
        case "Air": "air"
        case "Earth": "earth"
        default: "sparkle"
        }
    }

    private func timeString(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }

    private func minutesUntil(_ date: Date) -> Int {
        max(Int(ceil(date.timeIntervalSinceNow / 60)), 0)
    }

    private var liveSabbatCountdown: String {
        let remaining = max(sabbat.date.timeIntervalSince(now), 0)
        let totalSeconds = Int(remaining)
        let days = totalSeconds / 86_400
        let hours = (totalSeconds % 86_400) / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        let seconds = totalSeconds % 60

        return "\(days)d \(hours)h \(minutes)m \(seconds)s"
    }
}
