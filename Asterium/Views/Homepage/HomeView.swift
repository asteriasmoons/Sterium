//
//  HomeView.swift
//  Sterium
//

import SwiftUI
import SwiftData
import Combine
import CoreLocation

struct HomeView: View {
    @StateObject private var planetaryService = PlanetaryHourService()
    @State private var now = Date()
    @State private var aiCorrespondences: CurrentCorrespondencesAIResponse?
    @State private var currentCorrespondenceDayKey = Self.dayKey(for: Date())
    @State private var moonRiseSet: MoonRiseSetResult?
    @State private var showReleaseNotes = false
    @State private var showCustomize = false
    @State private var timingFieldActive = false

    @Query private var layouts: [HomeWidgetLayout]

    private let currentCorrespondencesService = CurrentCorrespondencesService()
    private let moonRiseSetCalculator = MoonRiseSetCalculator()

    private var moon: MoonPhaseData {
        MoonPhaseCalculator.calculate(for: now)
    }

    private var sabbat: SabbatInfo {
        DailySpiritualCalculator.nextSabbat(from: now)
    }

    private var planetaryDay: Planet {
        DailySpiritualCalculator.planetaryDay(for: now)
    }

    private var weekdayName: String {
        DailySpiritualCalculator.weekdayName(for: now)
    }

    private var correspondences: DailyCorrespondences {
        DailySpiritualCalculator.correspondences(for: planetaryDay)
    }

    private var correspondenceTitle: String {
        aiCorrespondences?.title ?? "Today's energies"
    }

    private var correspondenceMessage: String? {
        aiCorrespondences?.message
    }

    private var correspondencePlanet: String {
        aiCorrespondences?.planet ?? correspondences.planet.displayName
    }

    private var correspondencePlanetAsset: String {
        guard let planet = planet(from: correspondencePlanet) else {
            return planetAssetName(correspondences.planet)
        }

        return planetAssetName(planet)
    }

    private var correspondenceElement: String {
        aiCorrespondences?.element ?? correspondences.element
    }

    private var correspondenceColor: String {
        aiCorrespondences?.color ?? correspondences.color
    }

    private var correspondenceCrystal: String {
        aiCorrespondences?.crystal ?? correspondences.crystal
    }

    private var correspondenceHerb: String {
        aiCorrespondences?.herb ?? correspondences.herb
    }

    private var luckyHours: [LuckyHour] {
        DailySpiritualCalculator.luckyHours(from: planetaryService.result)
    }

    private var homeLayout: HomeWidgetLayout? {
        layouts.sorted(by: { $0.updatedAt > $1.updatedAt }).first
    }

    private var visibleWidgets: [HomeWidget] {
        homeLayout?.visibleWidgets ?? HomeWidget.defaultOrder
    }

    private var homeHeader: some View {
        HStack(alignment: .center) {
            AsteriumPageHeader(eyebrow: "TODAY'S", title: "Sterium")
            Spacer()
            Button { showCustomize = true } label: {
                Image("cogwavy")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(LGradients.header)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private func widgetView(for widget: HomeWidget) -> some View {
        switch widget {
        case .moon: currentMoonCard
        case .sabbat: upcomingSabbatCard
        case .planetaryDayHour: planetaryDayHourCard
        case .correspondences: correspondencesCard
        case .dailyNumerology: dailyNumerologyCard
        case .retrogradesTransits: retrogradesTransitsCard
        case .luckyHours: luckyHoursCard
        case .workingTiming: WorkingTimingCard(coordinate: planetaryService.coordinate, isFieldActive: $timingFieldActive)
        }
    }

    var body: some View {
        NavigationStack {
        ScrollViewReader { proxy in
        ScrollView {
            VStack(alignment: .leading, spacing: LSpacing.sectionGap) {
                homeHeader

                ForEach(visibleWidgets) { widget in
                    widgetView(for: widget)
                }
            }
            .padding(.horizontal, LSpacing.pageHorizontal)
            .padding(.bottom, timingFieldActive ? 420 : 120)
        }
        .scrollIndicators(.hidden)
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: timingFieldActive) { _, active in
            if active {
                withAnimation(.easeInOut(duration: 0.28)) {
                    proxy.scrollTo(HomeWidget.workingTiming.id, anchor: .center)
                }
            }
        }
        .background { AsteriumBackground() }
        .onReceive(
            Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        ) { date in
            now = date
            let updatedDayKey = Self.dayKey(for: date)

            guard updatedDayKey != currentCorrespondenceDayKey else {
                return
            }

            currentCorrespondenceDayKey = updatedDayKey

            updateMoonRiseSet(for: date)

            Task {
                await refreshCurrentCorrespondences()
            }
        }
        .task {
            updateMoonRiseSet(for: now)
            await loadCurrentCorrespondences()
        }
        .onChange(of: planetaryService.state) {
            Task {
                await loadCurrentCorrespondences()
            }
        }
        .onChange(of: planetaryService.coordinate?.latitude) {
            updateMoonRiseSet(for: now)
        }
        .onChange(of: planetaryService.coordinate?.longitude) {
            updateMoonRiseSet(for: now)
        }
        .onAppear {
            if ReleaseNotesTracker.hasUnseenRelease {
                showReleaseNotes = true
            }
        }
        .asteriumAdaptivePresentation(isPresented: $showReleaseNotes) {
            ReleaseNotesView()
        }
        .asteriumAdaptivePresentation(isPresented: $showCustomize) {
            HomeCustomizeView()
        }
        }
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

                HStack(spacing: 12) {
                    metricPill(
                        label: "MOONRISE",
                        value: moonRiseSetText(moonRiseSet?.moonrise),
                        asset: "chevup"
                    )
                    metricPill(
                        label: "MOONSET",
                        value: moonRiseSetText(moonRiseSet?.moonset),
                        asset: "chevdown"
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
                        value: "\(sabbat.countdown(from: now)) days",
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
                cardHeader(asset: "wand", eyebrow: "CURRENT CORRESPONDENCES", title: correspondenceTitle)

                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        metricPill(
                            label: "PLANET",
                            value: correspondencePlanet,
                            asset: correspondencePlanetAsset
                        )
                        metricPill(
                            label: "ELEMENT",
                            value: correspondenceElement,
                            asset: elementAssetName(correspondenceElement)
                        )
                    }

                    HStack(spacing: 12) {
                        metricPill(
                            label: "COLOR",
                            value: correspondenceColor,
                            asset: "paintdrop"
                        )
                        metricPill(
                            label: "CRYSTAL",
                            value: correspondenceCrystal,
                            asset: "crystalball"
                        )
                    }

                    metricPill(
                        label: "HERB",
                        value: correspondenceHerb,
                        asset: "seedling"
                    )
                }

                if let correspondenceMessage {
                    Text(correspondenceMessage)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(LColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var numerology: DailyNumerology {
        NumerologyCalculator.numerology(for: now)
    }

    private var dailyNumerologyCard: some View {
        let data = numerology
        return GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                cardHeader(asset: "numcal", eyebrow: "DAILY NUMEROLOGY", title: "Universal Day \(data.number)")

                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        metricPill(label: "NUMBER", value: "\(data.number)", asset: "hashtagwavy")
                        metricPill(label: "INTENTION", value: data.intention, asset: "wand")
                    }
                    HStack(spacing: 12) {
                        metricPill(label: "ARCANA", value: data.arcana, asset: "moontarot")
                        metricPill(label: "ARCHETYPE", value: data.archetype, asset: "crystalballhand")
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var skyEvents: (retrograde: RetrogradeEvent?, transits: [AstrologyTransit]) {
        AstrologyTransitCalculator().homeScreenEvents(for: now)
    }

    private var retrogradesTransitsCard: some View {
        let events = skyEvents
        let transits = events.transits

        return GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                cardHeader(asset: "retrograde", eyebrow: "RETROGRADES & TRANSITS", title: "Current sky")

                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        skyEventTile(
                            label: "RETROGRADE",
                            value: events.retrograde?.body.displayName ?? "None active",
                            asset: "retrograde"
                        )
                        skyTransitTile(transits.indices.contains(0) ? transits[0] : nil)
                    }

                    HStack(spacing: 12) {
                        skyTransitTile(transits.indices.contains(1) ? transits[1] : nil)
                        skyTransitTile(transits.indices.contains(2) ? transits[2] : nil)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func skyTransitTile(_ transit: AstrologyTransit?) -> some View {
        guard let transit else {
            return AnyView(skyEventTile(label: "TRANSIT", value: "None active", asset: "conjunction"))
        }

        return AnyView(
            skyEventTile(
                label: transit.aspect.tileLabel,
                value: "\(transit.firstBody.displayName) + \(transit.secondBody.displayName)",
                asset: transit.aspect.assetName
            )
        )
    }

    private func skyEventTile(label: String, value: String, asset: String) -> some View {
        metricPill(label: label, value: value, asset: asset)
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
        switch element.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "fire": "fire"
        case "water": "water"
        case "air": "air"
        case "earth": "earth"
        default: "sparkle"
        }
    }

    private func timeString(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }

    private func moonRiseSetText(_ date: Date?) -> String {
        guard planetaryService.coordinate != nil else {
            return "Location Needed"
        }

        guard let date else {
            return "None today"
        }

        return timeString(date)
    }

    private func updateMoonRiseSet(for date: Date) {
        guard let coordinate = planetaryService.coordinate else {
            moonRiseSet = nil
            return
        }

        moonRiseSet = moonRiseSetCalculator.result(
            for: date,
            coordinate: coordinate,
            timeZone: .autoupdatingCurrent
        )
    }

    private func minutesUntil(_ date: Date) -> Int {
        max(Int(ceil(date.timeIntervalSinceNow / 60)), 0)
    }

    private func loadCurrentCorrespondences() async {
        if let cachedResponse = currentCorrespondencesService.cachedResponse(
            for: currentCorrespondenceDayKey,
            planetaryDay: planetaryDay.displayName
        ) {
            print("[CurrentCorrespondences] using cached response", [
                "dayKey": currentCorrespondenceDayKey,
                "planetaryDay": planetaryDay.displayName,
                "planet": cachedResponse.planet,
                "element": cachedResponse.element
            ])
            aiCorrespondences = cachedResponse
            return
        }

        guard planetaryService.result != nil ||
              planetaryService.state == .locationDenied ||
              isPlanetaryServiceUnavailable
        else {
            print("[CurrentCorrespondences] waiting for planetary context", [
                "dayKey": currentCorrespondenceDayKey,
                "planetaryDay": planetaryDay.displayName,
                "state": "\(planetaryService.state)"
            ])
            return
        }

        await refreshCurrentCorrespondences()
    }

    private func refreshCurrentCorrespondences() async {
        let request = CurrentCorrespondencesAIRequest(
            date: now.formatted(date: .numeric, time: .omitted),
            weekday: weekdayName,
            planetaryDay: planetaryDay.displayName,
            planetaryHour: planetaryService.result?.currentPlanet.displayName,
            nextPlanetaryHour: planetaryService.result?.nextPlanet.displayName,
            moonPhase: moon.phaseName,
            moonSign: moon.signName,
            moonIlluminationPercent: moon.illuminationPercent,
            upcomingSabbat: sabbat.name,
            daysUntilSabbat: sabbat.countdown(from: now)
        )

        do {
            print("[CurrentCorrespondences] backend request", [
                "dayKey": currentCorrespondenceDayKey,
                "date": request.date,
                "weekday": request.weekday,
                "planetaryDay": request.planetaryDay,
                "planetaryHour": request.planetaryHour ?? "nil",
                "nextPlanetaryHour": request.nextPlanetaryHour ?? "nil",
                "moonPhase": request.moonPhase,
                "moonSign": request.moonSign,
                "upcomingSabbat": request.upcomingSabbat
            ])

            aiCorrespondences = try await currentCorrespondencesService.responseForToday(
                dayKey: currentCorrespondenceDayKey,
                requestBody: request
            )

            if let aiCorrespondences {
                print("[CurrentCorrespondences] backend/cache response", [
                    "dayKey": currentCorrespondenceDayKey,
                    "title": aiCorrespondences.title,
                    "planet": aiCorrespondences.planet,
                    "element": aiCorrespondences.element,
                    "color": aiCorrespondences.color,
                    "crystal": aiCorrespondences.crystal,
                    "herb": aiCorrespondences.herb
                ])
            }
        } catch {
            print("[CurrentCorrespondences] backend failed", [
                "dayKey": currentCorrespondenceDayKey,
                "planetaryDay": request.planetaryDay,
                "planetaryHour": request.planetaryHour ?? "nil",
                "error": error.localizedDescription
            ])
            aiCorrespondences = nil
        }
    }

    private func planet(from name: String) -> Planet? {
        Planet.allCases.first {
            $0.displayName.caseInsensitiveCompare(name) == .orderedSame ||
                $0.rawValue.caseInsensitiveCompare(name) == .orderedSame
        }
    }

    private var isPlanetaryServiceUnavailable: Bool {
        if case .unavailable = planetaryService.state {
            return true
        }

        return false
    }

    private var liveSabbatCountdown: String {
        let remaining = max(sabbat.date.timeIntervalSince(now), 0)
        let totalSeconds = Int(remaining)
        let days = totalSeconds / 86_400
        let hours = (totalSeconds % 86_400) / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        let seconds = totalSeconds % 60

        return "\(days)D \(hours)H \(minutes)M \(seconds)S"
    }

    private static func dayKey(for date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .autoupdatingCurrent

        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0

        return String(format: "%04d-%02d-%02d", year, month, day)
    }
}
