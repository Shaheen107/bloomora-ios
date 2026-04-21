import Foundation
import Observation

enum DrinkKind: String, CaseIterable, Codable, Identifiable {
    case water
    case milk
    case coffee
    case drink
    case milkTea
    case tea
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .water:    "Water"
        case .milk:     "Milk"
        case .coffee:   "Coffee"
        case .drink:    "Drink"
        case .milkTea:  "MilkTea"
        case .tea:      "Tea"
        case .other:    "Other"
        }
    }

    var stepAmount: Int {
        switch self {
        case .water:                        300
        case .milk:                         250
        case .coffee:                       100
        case .drink, .milkTea, .tea, .other: 200
        }
    }
}

enum FlowerSpecies: String, CaseIterable, Codable, Identifiable {
    case sunflower
    case blueBloom
    case lily
    case rose

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sunflower:  "Sunflower"
        case .blueBloom:  "Blue Flower"
        case .lily:       "Lily"
        case .rose:       "Rose"
        }
    }
}

enum FlowerStage: Int, CaseIterable, Codable {
    case seed   = 0
    case sprout = 1
    case bud    = 2
    case bloom  = 3

    func homeCopy(progress: Double) -> String {
        switch self {
        case .seed:   "A tiny start. Keep sipping to wake your flower."
        case .sprout: "Roots are settling in. You're building a healthy rhythm."
        case .bud:    "Almost there. One more round of hydration opens today's bloom."
        case .bloom:  progress >= 1 ? "Today's flower is fully open." : "Your blossom is opening beautifully."
        }
    }
}

struct DrinkEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let kind: DrinkKind
    let amount: Int
    let loggedAt: Date

    init(id: UUID = UUID(), kind: DrinkKind, amount: Int, loggedAt: Date) {
        self.id = id
        self.kind = kind
        self.amount = amount
        self.loggedAt = loggedAt
    }
}

struct GardenFlower: Identifiable, Codable, Hashable {
    let id: UUID
    let plantedOn: Date
    let species: FlowerSpecies

    init(id: UUID = UUID(), plantedOn: Date, species: FlowerSpecies) {
        self.id = id
        self.plantedOn = plantedOn
        self.species = species
    }
}

struct ReminderSlot: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let hour: Int
    let minute: Int
    var enabled: Bool

    init(id: UUID = UUID(), title: String, hour: Int, minute: Int, enabled: Bool) {
        self.id = id
        self.title = title
        self.hour = hour
        self.minute = minute
        self.enabled = enabled
    }

    var date: Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: DateComponents(hour: hour, minute: minute)) ?? .now
    }
}

enum BloomoraFormatters {
    static let homeDate: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "MM/dd/yyyy"
        return f
    }()

    static let monthTitle: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy/MM"
        return f
    }()

    static let dayNumber: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "d"
        return f
    }()

    static let reminderTime: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "h:mm a"
        return f
    }()
}

@Observable
final class BloomoraStore {
    var dailyGoal: Int
    var selectedDate: Date
    var reminders: [ReminderSlot]

    private(set) var entries: [DrinkEntry]
    private(set) var flowers: [GardenFlower]

    private let defaults: UserDefaults
    private let calendar: Calendar
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private let goalKey      = "Bloomora.dailyGoal"
    private let entriesKey   = "Bloomora.entries"
    private let flowersKey   = "Bloomora.flowers"
    private let remindersKey = "Bloomora.reminders"

    init(defaults: UserDefaults = .standard) {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1
        calendar = cal
        self.defaults = defaults

        // Default daily goal is 2000ml (matches screenshot)
        dailyGoal    = defaults.object(forKey: "Bloomora.dailyGoal") as? Int ?? 2000
        selectedDate = cal.startOfDay(for: .now)
        entries      = []
        flowers      = []
        reminders    = Self.defaultReminders

        if let saved = load([DrinkEntry].self,   key: entriesKey)   { entries   = saved }
        if let saved = load([GardenFlower].self, key: flowersKey)   { flowers   = saved }
        if let saved = load([ReminderSlot].self, key: remindersKey) { reminders = saved }

        if !entries.isEmpty {
            ensureFlowerRegistry()
        }
    }

    // MARK: Computed
    var unlockedFlowerCount: Int { flowers.count }

    var sortedFlowers: [GardenFlower] {
        flowers.sorted { $0.plantedOn > $1.plantedOn }
    }

    var hasLoggedEntries: Bool {
        !entries.isEmpty
    }

    var weekdaySymbols: [String] {
        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    }

    // MARK: Mutations
    func addDrink(_ kind: DrinkKind, on date: Date = .now) {
        let resolved = calendar.date(
            bySettingHour:   calendar.component(.hour,   from: .now),
            minute:          calendar.component(.minute, from: .now),
            second: 0,
            of: date
        ) ?? date

        entries.append(DrinkEntry(kind: kind, amount: kind.stepAmount, loggedAt: resolved))
        ensureFlower(for: resolved)
        save(entries, key: entriesKey)
        save(flowers, key: flowersKey)
    }

    func updateDailyGoal(to amount: Int) {
        dailyGoal = max(250, amount)
        defaults.set(dailyGoal, forKey: goalKey)
    }

    func updateReminder(_ id: UUID, isEnabled: Bool) {
        guard let index = reminders.firstIndex(where: { $0.id == id }) else { return }
        reminders[index].enabled = isEnabled
        save(reminders, key: remindersKey)
    }

    // MARK: Queries
    func totalIntake(on date: Date) -> Int {
        entries
            .filter { calendar.isDate($0.loggedAt, inSameDayAs: date) }
            .map(\.amount)
            .reduce(0, +)
    }

    func amount(of kind: DrinkKind, on date: Date) -> Int {
        entries
            .filter { $0.kind == kind && calendar.isDate($0.loggedAt, inSameDayAs: date) }
            .map(\.amount)
            .reduce(0, +)
    }

    func progressRatio(on date: Date) -> Double {
        let goal = max(dailyGoal, 1)
        return min(Double(totalIntake(on: date)) / Double(goal), 1)
    }

    func stage(for date: Date) -> FlowerStage {
        let p = progressRatio(on: date)
        switch p {
        case ..<0.30: return .seed
        case ..<0.60: return .sprout
        case ..<1:    return .bud
        default:      return .bloom
        }
    }

    func flower(on date: Date) -> GardenFlower {
        let day = calendar.startOfDay(for: date)
        if let f = flowers.first(where: { calendar.isDate($0.plantedOn, inSameDayAs: day) }) {
            return f
        }
        return GardenFlower(plantedOn: day, species: species(for: day))
    }

    func monthGrid(for month: Date) -> [Date?] {
        let monthStart   = startOfMonth(for: month)
        let numberOfDays = calendar.range(of: .day, in: .month, for: monthStart) ?? 1..<2
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leading      = (firstWeekday - calendar.firstWeekday + 7) % 7

        var grid = Array<Date?>(repeating: nil, count: leading)
        for day in numberOfDays {
            if let d = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                grid.append(d)
            }
        }
        while grid.count % 7 != 0 { grid.append(nil) }
        return grid
    }

    func startOfMonth(for date: Date) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }

    func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }

    // MARK: Private helpers
    private func ensureFlowerRegistry() {
        let days = Set(entries.map { calendar.startOfDay(for: $0.loggedAt) })
        for day in days where !flowers.contains(where: { calendar.isDate($0.plantedOn, inSameDayAs: day) }) {
            flowers.append(GardenFlower(plantedOn: day, species: species(for: day)))
        }
        save(flowers, key: flowersKey)
    }

    private func ensureFlower(for date: Date) {
        let day = calendar.startOfDay(for: date)
        guard !flowers.contains(where: { calendar.isDate($0.plantedOn, inSameDayAs: day) }) else { return }
        flowers.append(GardenFlower(plantedOn: day, species: species(for: day)))
    }

    private func species(for date: Date) -> FlowerSpecies {
        let ordinal = calendar.ordinality(of: .day, in: .era, for: date) ?? 0
        return FlowerSpecies.allCases[ordinal % FlowerSpecies.allCases.count]
    }

    private func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static let defaultReminders: [ReminderSlot] = [
        ReminderSlot(title: "Morning bloom",     hour:  9, minute:  0, enabled: true),
        ReminderSlot(title: "Midday sip",        hour: 12, minute: 30, enabled: true),
        ReminderSlot(title: "Afternoon refresh", hour: 15, minute: 30, enabled: true),
        ReminderSlot(title: "Evening top-up",    hour: 18, minute: 30, enabled: false)
    ]
}
