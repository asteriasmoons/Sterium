//
//  NumerologyCalculator.swift
//  Sterium
//
//  Local Daily Numerology. Computes the Universal Day Number for a calendar
//  date (no network, no API) and maps 1–9 to their intention, arcana, and
//  archetype. Calculation stays separate from presentation, and the 1–9 data
//  is centralized here so the UI never hard-codes strings.
//

import Foundation

/// The centralized meaning for a single Universal Day Number (1–9).
/// Intention and Archetype are intentionally short for compact tiles.
struct DailyNumerology: Identifiable, Hashable {
    let number: Int
    let intention: String
    let arcana: String
    let archetype: String

    var id: Int { number }
}

enum NumerologyCalculator {

    /// The canonical 1–9 correspondence table.
    static let table: [Int: DailyNumerology] = [
        1: DailyNumerology(number: 1, intention: "Initiation",   arcana: "The Magician",       archetype: "The Pioneer"),
        2: DailyNumerology(number: 2, intention: "Harmony",      arcana: "The High Priestess", archetype: "The Diplomat"),
        3: DailyNumerology(number: 3, intention: "Expression",   arcana: "The Empress",        archetype: "The Creator"),
        4: DailyNumerology(number: 4, intention: "Foundation",   arcana: "The Emperor",        archetype: "The Builder"),
        5: DailyNumerology(number: 5, intention: "Exploration",  arcana: "The Hierophant",     archetype: "The Explorer"),
        6: DailyNumerology(number: 6, intention: "Nurturing",    arcana: "The Lovers",         archetype: "The Caregiver"),
        7: DailyNumerology(number: 7, intention: "Reflection",   arcana: "The Chariot",        archetype: "The Seeker"),
        8: DailyNumerology(number: 8, intention: "Empowerment",  arcana: "Strength",           archetype: "The Achiever"),
        9: DailyNumerology(number: 9, intention: "Completion",   arcana: "The Hermit",         archetype: "The Humanitarian")
    ]

    /// The Universal Day Number (1–9) for a calendar date. Sums every digit of
    /// the full date (month, day, four-digit year) and reduces repeatedly to a
    /// single digit.
    ///
    ///     Sep 9, 2026 -> 0+9 + 0+9 + 2+0+2+6 = 28 -> 2+8 = 10 -> 1+0 = 1
    static func universalDayNumber(for date: Date = Date(), calendar: Calendar = .current) -> Int {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let month = components.month ?? 1
        let day = components.day ?? 1
        let year = components.year ?? 2000

        let total = digitSum(month) + digitSum(day) + digitSum(year)
        return reduceToSingleDigit(total)
    }

    /// The full numerology meaning for a calendar date.
    static func numerology(for date: Date = Date(), calendar: Calendar = .current) -> DailyNumerology {
        let number = universalDayNumber(for: date, calendar: calendar)
        return table[number] ?? table[1]!
    }

    // MARK: - Reduction

    /// Reduces a value to a single digit 1–9 by repeatedly summing its digits.
    static func reduceToSingleDigit(_ value: Int) -> Int {
        var n = abs(value)
        while n > 9 {
            n = digitSum(n)
        }
        // Real calendar dates never sum to 0; guard defensively so callers
        // always receive a valid 1–9 key.
        return n == 0 ? 9 : n
    }

    private static func digitSum(_ value: Int) -> Int {
        var n = abs(value)
        var sum = 0
        while n > 0 {
            sum += n % 10
            n /= 10
        }
        return sum
    }
}
