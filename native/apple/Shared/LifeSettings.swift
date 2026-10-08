import Foundation

enum TimeUnit: String, Codable, CaseIterable, Identifiable {
    case days, hours, minutes
    var id: String { rawValue }
    var seconds: Double {
        switch self { case .days: return 86400; case .hours: return 3600; case .minutes: return 60 }
    }
    var title: String { rawValue.capitalized }
}

struct LifeSettings: Codable, Equatable {
    var bornAt: Date
    var targetAt: Date
    var targetAge: Int
    var exactBirthday: Bool
    var unit: TimeUnit
    var updatedAt: Date
    var changeID: String

    static func addingYears(_ years: Int, to date: Date) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .year, value: years, to: date) ?? date
    }
    static func initial(now: Date = Date()) -> LifeSettings {
        let born = addingYears(-37, to: now)
        return LifeSettings(bornAt: born, targetAt: addingYears(60, to: born), targetAge: 60,
            exactBirthday: false, unit: .days, updatedAt: Date(timeIntervalSince1970: 0), changeID: UUID().uuidString)
    }
    func age(at now: Date = Date()) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        var years = calendar.component(.year, from: now) - calendar.component(.year, from: bornAt)
        if now < Self.addingYears(years, to: bornAt) { years -= 1 }
        return max(0, years)
    }
    func remaining(at now: Date) -> Double { max(0, targetAt.timeIntervalSince(now)) }
    func total(_ unit: TimeUnit, at now: Date) -> Int { Int(floor(remaining(at: now) / unit.seconds)) }
    func fraction(at now: Date) -> Double { min(1, max(0, remaining(at: now) / max(1, targetAt.timeIntervalSince(bornAt)))) }
    func valid(now: Date = Date()) -> Bool {
        bornAt <= now && targetAt > bornAt && (1...120).contains(targetAge)
            && abs(targetAt.timeIntervalSince(Self.addingYears(targetAge, to: bornAt))) < 86400
            && bornAt.timeIntervalSince1970.isFinite && targetAt.timeIntervalSince1970.isFinite
    }
    func newer(than other: LifeSettings) -> Bool {
        updatedAt == other.updatedAt ? changeID > other.changeID : updatedAt > other.updatedAt
    }
    func updated(age: Int, target: Int, birthday: Date?, clearBirthday: Bool = false, now: Date = Date()) throws -> LifeSettings {
        guard (0...119).contains(age), target > age, target <= 120 else { throw TimelineError.invalidAges }
        var result = self
        if let birthday {
            guard birthday <= now else { throw TimelineError.futureBirthday }
            result.bornAt = Calendar(identifier: .gregorian).startOfDay(for: birthday)
            result.exactBirthday = true
        } else if age != self.age(at: now) || (clearBirthday && exactBirthday) {
            result.bornAt = Self.addingYears(-age, to: now)
            result.exactBirthday = false
        }
        guard result.age(at: now) < target, result.age(at: now) < 120 else { throw TimelineError.invalidAges }
        result.targetAge = target
        result.targetAt = Self.addingYears(target, to: result.bornAt)
        result.updatedAt = now
        result.changeID = UUID().uuidString
        return result
    }
}

enum TimelineError: LocalizedError {
    case invalidAges, futureBirthday
    var errorDescription: String? {
        switch self {
        case .invalidAges: return "Enter an age from 0 to 119 and a higher milestone, up to 120."
        case .futureBirthday: return "Choose a birthday in the past."
        }
    }
}
