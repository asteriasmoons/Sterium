
//
//  GrimoireEntryTypeHelpers.swift
//  Asterium
//

import SwiftUI

extension GrimoireEntryType {

    var displayName: String {
        switch self {
        case .journal:          return "Journal"
        case .workingDocument:  return "Working Docs"
        case .workingResult:    return "Working Results"
        case .dream:            return "Dreams"
        case .synchronicity:    return "Synchronicities"
        case .pathwork:         return "Pathwork"
        case .moonPhase:        return "Moon Phases"
        case .deityDevotion:    return "Deity Devotion"
        case .divination:       return "Divination"
        case .meditation:       return "Meditation"
        case .shadowWork:       return "Shadow Work"
        case .manifestation:    return "Manifestation"
        case .experience:       return "Custom Experience"
        }
    }

    var icon: String {
        switch self {
        case .journal:          return "openbook"
        case .workingDocument:  return "wand"
        case .workingResult:    return "starnote"
        case .dream:            return "moonzs"
        case .synchronicity:    return "sparklecircle"
        case .pathwork:         return "journey"
        case .moonPhase:        return "themoon"
        case .deityDevotion:    return "starchalice"
        case .divination:       return "tarotcards"
        case .meditation:       return "meditate"
        case .shadowWork:       return "eyeslash"
        case .manifestation:    return "startarget"
        case .experience:       return "starry"
        }
    }

    var singularName: String {
        switch self {
        case .journal:          return "Journal"
        case .workingDocument:  return "Working Document"
        case .workingResult:    return "Working Result"
        case .dream:            return "Dream"
        case .synchronicity:    return "Synchronicity"
        case .pathwork:         return "Pathwork"
        case .moonPhase:        return "Moon Phase"
        case .deityDevotion:    return "Deity Devotion"
        case .divination:       return "Divination"
        case .meditation:       return "Meditation"
        case .shadowWork:       return "Shadow Work"
        case .manifestation:    return "Manifestation"
        case .experience:       return "Experience"
        }
    }

    var color: Color {
        switch self {
        case .journal:          return LColors.gradientPurple
        case .workingDocument:  return LColors.gradientBlue
        case .workingResult:    return LColors.gradientCyan
        case .dream:            return LColors.gradientDeepPurple
        case .synchronicity:    return LColors.gradientYellow
        case .pathwork:         return LColors.gradientPink
        case .moonPhase:        return LColors.accent
        case .deityDevotion:    return LColors.gradientPurple.opacity(0.8)
        case .divination:       return LColors.gradientBlue.opacity(0.8)
        case .meditation:       return LColors.gradientCyan.opacity(0.8)
        case .shadowWork:       return LColors.gradientPink.opacity(0.8)
        case .manifestation:    return LColors.gradientYellow.opacity(0.8)
        case .experience:       return LColors.gradientDeepPurple.opacity(0.8)
        }
    }
}

// MARK: - Enum Display Names

extension WorkingCategory {
    var displayName: String {
        switch self {
        case .protection:  return "Protection"
        case .prosperity:  return "Prosperity"
        case .love:        return "Love"
        case .healing:     return "Healing"
        case .banishing:   return "Banishing"
        case .cleansing:   return "Cleansing"
        case .divination:  return "Divination"
        case .other:       return "Other"
        }
    }
}

extension WorkingKind {
    var displayName: String {
        switch self {
        case .spell:  return "Spell"
        case .ritual: return "Ritual"
        }
    }
}

extension WorkingOutcome {
    var displayName: String {
        switch self {
        case .successful: return "Successful"
        case .partial:    return "Partial"
        case .none:       return "None"
        case .unsure:     return "Unsure"
        }
    }
}

extension RepeatDecision {
    var displayName: String {
        switch self {
        case .yes:   return "Yes"
        case .no:    return "No"
        case .maybe: return "Maybe"
        }
    }
}

extension DreamType {
    var displayName: String {
        switch self {
        case .lucid:     return "Lucid"
        case .nightmare: return "Nightmare"
        case .recurring: return "Recurring"
        case .symbolic:  return "Symbolic"
        case .prophetic: return "Prophetic"
        case .ordinary:  return "Ordinary"
        case .unsure:    return "Unsure"
        }
    }
}

extension SleepQuality {
    var displayName: String {
        switch self {
        case .veryPoor:  return "Very Poor"
        case .poor:      return "Poor"
        case .fair:      return "Fair"
        case .good:      return "Good"
        case .excellent: return "Excellent"
        }
    }
}

extension PathworkStatus {
    var displayName: String {
        switch self {
        case .exploring:   return "Exploring"
        case .active:      return "Active"
        case .paused:      return "Paused"
        case .integrating: return "Integrating"
        case .completed:   return "Completed"
        }
    }
}

extension ManifestationStatus {
    var displayName: String {
        switch self {
        case .inProgress:    return "In Progress"
        case .manifested:    return "Manifested"
        case .notManifested: return "Not Manifested"
        case .released:      return "Released"
        }
    }
}
