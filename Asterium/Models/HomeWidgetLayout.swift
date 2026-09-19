//
//  HomeWidgetLayout.swift
//  Sterium
//
//  Persisted customization for the homepage widgets: the order the user
//  arranged them in, and which ones they've hidden. Hiding never deletes a
//  widget's placement — it keeps its spot in `order` so re-showing returns it
//  to where it was. Lives in the shared store so the layout syncs via CloudKit.
//

import Foundation
import SwiftData

enum HomeWidget: String, CaseIterable, Identifiable {
    case moon
    case sabbat
    case planetaryDayHour
    case correspondences
    case dailyNumerology
    case retrogradesTransits
    case luckyHours
    case workingTiming

    var id: String { rawValue }

    static var defaultOrder: [HomeWidget] { allCases }

    var title: String {
        switch self {
        case .moon: return "Current Moon"
        case .sabbat: return "Upcoming Sabbat"
        case .planetaryDayHour: return "Planetary Day & Hour"
        case .correspondences: return "Current Correspondences"
        case .dailyNumerology: return "Daily Numerology"
        case .retrogradesTransits: return "Retrogrades & Transits"
        case .luckyHours: return "Lucky Hours"
        case .workingTiming: return "Working Timing Finder"
        }
    }

    var subtitle: String {
        switch self {
        case .moon: return "Phase, sign, illumination & moonrise"
        case .sabbat: return "The next sabbat and its countdown"
        case .planetaryDayHour: return "Ruling planet of the day & hour"
        case .correspondences: return "Today's magical correspondences"
        case .dailyNumerology: return "Today's universal day number"
        case .retrogradesTransits: return "The most important sky events right now"
        case .luckyHours: return "The best planetary hours today"
        case .workingTiming: return "Find the best time for a working"
        }
    }

    var icon: String {
        switch self {
        case .moon: return "moonstar"
        case .sabbat: return "ringstarcal"
        case .planetaryDayHour: return "thesun"
        case .correspondences: return "wand"
        case .dailyNumerology: return "numcal"
        case .retrogradesTransits: return "retrograde"
        case .luckyHours: return "clockwavy"
        case .workingTiming: return "goalsparkle"
        }
    }
}

@Model
final class HomeWidgetLayout {
    var id: UUID = UUID()
    /// JSON array of widget raw ids in display order (all widgets, shown + hidden).
    var orderStorage: String = ""
    /// JSON array of widget raw ids that are currently hidden.
    var hiddenStorage: String = ""
    var updatedAt: Date = Date()

    init(id: UUID = UUID()) {
        self.id = id
        self.orderStorage = ""
        self.hiddenStorage = ""
        self.updatedAt = Date()
    }
}

extension HomeWidgetLayout {
    var order: [HomeWidget] {
        get {
            guard let data = orderStorage.data(using: .utf8),
                  let ids = try? JSONDecoder().decode([String].self, from: data) else { return [] }
            return ids.compactMap { HomeWidget(rawValue: $0) }
        }
        set {
            let ids = newValue.map(\.rawValue)
            if let data = try? JSONEncoder().encode(ids), let json = String(data: data, encoding: .utf8) {
                orderStorage = json
            }
        }
    }

    var hidden: Set<HomeWidget> {
        get {
            guard let data = hiddenStorage.data(using: .utf8),
                  let ids = try? JSONDecoder().decode([String].self, from: data) else { return [] }
            return Set(ids.compactMap { HomeWidget(rawValue: $0) })
        }
        set {
            let ids = newValue.map(\.rawValue).sorted()
            if let data = try? JSONEncoder().encode(ids), let json = String(data: data, encoding: .utf8) {
                hiddenStorage = json
            }
        }
    }

    /// The full ordering, with any widgets missing from storage (e.g. newly
    /// added in an app update) inserted at their canonical default position —
    /// i.e. directly after the nearest preceding default-order widget that the
    /// user already has — so a new widget lands where it belongs rather than at
    /// the bottom.
    var resolvedOrder: [HomeWidget] {
        var result = order
        for widget in HomeWidget.defaultOrder where result.contains(widget) == false {
            result.insert(widget, at: defaultInsertionIndex(for: widget, in: result))
        }
        return result
    }

    private func defaultInsertionIndex(for widget: HomeWidget, in current: [HomeWidget]) -> Int {
        guard let defaultIndex = HomeWidget.defaultOrder.firstIndex(of: widget) else {
            return current.count
        }
        for i in stride(from: defaultIndex - 1, through: 0, by: -1) {
            if let existing = current.firstIndex(of: HomeWidget.defaultOrder[i]) {
                return existing + 1
            }
        }
        return 0
    }

    /// Widgets to actually render on the homepage, in order.
    var visibleWidgets: [HomeWidget] {
        let hiddenSet = hidden
        return resolvedOrder.filter { hiddenSet.contains($0) == false }
    }
}
