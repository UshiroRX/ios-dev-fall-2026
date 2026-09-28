// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Deck Register

// 1.1
enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine

    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab:    return 3
        case .engine: return 4
        case .cargo:  return 5
        }
    }
}

for deck in Deck.allCases {
    print(deck.rawValue, "priority", deck.evacuationPriority)
}

// 1.2
enum AlarmLevel: Int {
    case green = 0, yellow, orange, red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let step = min(max(mass, 0) / 500, AlarmLevel.red.rawValue)
        return AlarmLevel(rawValue: step) ?? .red
    }
}

print(AlarmLevel.level(forTotalMass: 0))      // green
print(AlarmLevel.level(forTotalMass: 940))    // yellow
print(AlarmLevel.level(forTotalMass: 4000))   // red


// MARK: Level 2 · The Manifest

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

// 2.2
func parseEntry(_ line: String) -> ManifestEntry {
    let f = fields(line)
    if f.count == 3, f[0] == "crate", let id = Int(f[1]), let mass = Int(f[2]) {
        return .crate(id: id, massKg: mass)
    }
    if f.count == 3, f[0] == "container", let mass = Int(f[2]) {
        return .container(code: f[1], massKg: mass)
    }
    if f.count == 4, f[0] == "livestock", let count = Int(f[2]), let perUnit = Int(f[3]) {
        return .livestock(species: f[1], count: count, massPerUnitKg: perUnit)
    }
    return .unknown(raw: line)
}

print(parseEntry("livestock:lab mice:12:2"))   // livestock(species: "lab mice", count: 12, massPerUnitKg: 2)
print(parseEntry("crate:104:abc"))             // unknown(raw: "crate:104:abc")

// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case let .crate(_, massKg):                     return massKg
    case let .container(_, massKg):                 return massKg
    case let .livestock(_, count, massPerUnitKg):   return count * massPerUnitKg
    case .unknown:                                  return 0
    }
}

var totalMass = 0
var unknownCount = 0
for line in rawManifest {
    let entry = parseEntry(line)
    if case .unknown = entry { unknownCount += 1 }
    totalMass += mass(of: entry)
}
print("Unknown lines:", unknownCount)

let A = totalMass
print("A =", A)


// MARK: Level 3 · Crew Snapshots

// 3.1
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        oxygen = max(0, oxygen - amount)
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

var probe = CrewSnapshot.rookie(named: "Probe")
probe.breathe(150)
probe.move(to: .cargo)
print(probe.oxygen, probe.deck)    // 0 cargo
probe.reviveInMedbay()
print(probe.oxygen, probe.deck)    // 100 medbay

// 3.2
var builtRoster: [CrewSnapshot] = []
for record in crewData {
    guard let deck = Deck(rawValue: record.deck) else {
        print("Warning: \(record.name) is on unknown deck '\(record.deck)', skipped")
        continue
    }
    builtRoster.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
}
let crewRoster = builtRoster
print("Roster:", crewRoster.count, "crew")

func snapshot(named name: String) -> CrewSnapshot? {
    for member in crewRoster where member.name == name {
        return member
    }
    return nil
}

// 3.3 · Value-semantics demonstration
var original = CrewSnapshot.rookie(named: "Aliya")

print("1. copy  | original before:", original.oxygen)
var copy = original
copy.breathe(30)
print("   copy after breathe:", copy.oxygen, "| original after:", original.oxygen)   // 70 | 100

func drainCopy(_ member: CrewSnapshot) {
    var local = member
    local.breathe(50)
    print("   inside plain func:", local.oxygen)
}
print("2. plain | original before:", original.oxygen)
drainCopy(original)
print("   original after:", original.oxygen)                                         // 100

func drainInPlace(_ member: inout CrewSnapshot) {
    member.breathe(50)
}
print("3. inout | original before:", original.oxygen)
drainInPlace(&original)
print("   original after:", original.oxygen)                                         // 50


// MARK: Level 4 · The Teleport Pod

// 4.1
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    // Structs get a free memberwise init. Classes don't: a class can be
    // inherited, so Swift won't guess how to initialize it — you write init.
    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        guard occupant == nil, chargeLevel >= 20 else { return false }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let crew = occupant else { return nil }
        chargeLevel -= 20
        occupant = nil
        return crew
    }
}

// 4.2 · Charge ledger
let ledgerPod = TeleportPod(id: "P-1", chargeLevel: 100)
for name in ["Timur", "Dana", "Nurlan"] {
    if let member = snapshot(named: name) {
        let loaded = ledgerPod.load(member)
        let arrived = ledgerPod.fire()
        print("\(name): loaded \(loaded), arrived \(arrived?.name ?? "nobody"), charge \(ledgerPod.chargeLevel)")
    }
}
let emptyShot = ledgerPod.fire()
print("Empty fire: arrived \(emptyShot?.name ?? "nobody"), charge \(ledgerPod.chargeLevel)")

let C = ledgerPod.chargeLevel
print("C =", C)

// 4.3 · Reference-semantics demonstration
let podOne = TeleportPod(id: "R-1", chargeLevel: 100)
let podTwo = podOne
podTwo.chargeLevel = 30
print("class:  podOne", podOne.chargeLevel, "| podTwo", podTwo.chargeLevel)    // 30 | 30

let snapOne = CrewSnapshot.rookie(named: "Ruslan")
var snapTwo = snapOne
snapTwo.oxygen = 30
print("struct: snapOne", snapOne.oxygen, "| snapTwo", snapTwo.oxygen)          // 100 | 30

// Rule: assigning a class copies the reference (two names, one object);
// assigning a struct copies the value (two independent objects).


// MARK: Level 5 · Station Systems

// 5.1
// Class: there is one station, and every system must see the same live state.
final class Station {
    let callSign: String
    var oxygenByDeck: [Deck: Int]

    var hullIntegrity: Int {
        willSet { print("Hull: \(hullIntegrity) -> \(newValue)") }
        didSet  { hullIntegrity = min(max(hullIntegrity, 0), 100) }
    }

    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        return "\(self.callSign): hull \(self.hullIntegrity)%, O2 total \(self.totalOxygen)"
    }()

    var totalOxygen: Int {
        var total = 0
        for (_, level) in oxygenByDeck {
            total += level
        }
        return total
    }

    var averageOxygen: Int {
        get {
            oxygenByDeck.isEmpty ? 0 : totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in oxygenByDeck.keys {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, readings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        self.hullIntegrity = 100
        var byDeck: [Deck: Int] = [:]
        for reading in readings {
            if let deck = Deck(rawValue: reading.deck) {
                byDeck[deck] = reading.oxygen
            }
        }
        self.oxygenByDeck = byDeck
    }
}

let station = Station(callSign: "ALMA-7", readings: deckReadings)

let B = station.averageOxygen
print("B =", B)
print("Total O2:", station.totalOxygen)

// lazy: built on first access only
print("Before diagnostics access")
print(station.fullDiagnostics)    // "Running full scan..." printed here
print(station.fullDiagnostics)    // no scan the second time

let untouched = Station(callSign: "ALMA-8", readings: deckReadings)
print("ALMA-8 created, diagnostics never touched — no scan:", untouched.callSign)

station.averageOxygen = 50
print("After setting average to 50:", station.oxygenByDeck[.cargo] ?? 0, station.totalOxygen)

// 5.2 · The clamp trap
station.hullIntegrity = 130
print("hull:", station.hullIntegrity)   // 100
station.hullIntegrity = -40
print("hull:", station.hullIntegrity)   // 0
station.hullIntegrity = 55
print("hull:", station.hullIntegrity)   // 55
// No infinite loop: assigning a property inside its own didSet
// does not trigger the observers again.


// MARK: Level 6 · Incident Reports

/*
// Report 1
var roster = crewRoster
for var member in roster {
    member.oxygen -= 10
}
print(roster[0].oxygen)   // author expected the crew to have lost oxygen

// Report 2
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = podA
podB.chargeLevel = 0
print(podA.chargeLevel)   // author expected 100

// Report 3
struct Logbook {
    var entries: [String] = []
    func add(_ entry: String) {
        entries.append(entry)
    }
}

// Report 4
let snapshot = CrewSnapshot.rookie(named: "Dana")
snapshot.oxygen = 40

let pod = TeleportPod(id: "B", chargeLevel: 50)
pod.chargeLevel = 10
*/

// Report 1 — compiles, wrong.
//   Expected: everyone loses 10 oxygen. Actual: roster is unchanged.
//   Rule: `for var member` gives a COPY of each struct; the copy is changed and thrown away.
//   Fix: change the array element itself, by index.
var fixedRoster = crewRoster
for i in fixedRoster.indices {
    fixedRoster[i].breathe(10)
}
print("Report 1 fix:", crewRoster[0].oxygen, "->", fixedRoster[0].oxygen)   // 62 -> 52

// Report 2 — compiles, wrong.
//   Expected: podA stays 100. Actual: prints 0.
//   Rule: classes are reference types; podB = podA copies the reference, both point to one pod.
//   Fix: create a separate pod.
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = TeleportPod(id: "B", chargeLevel: podA.chargeLevel)
podB.chargeLevel = 0
print("Report 2 fix:", podA.chargeLevel)   // 100

// Report 3 — does NOT compile.
//   error: cannot use mutating member on immutable value: 'self' is immutable
//   Rule: struct methods can't change stored properties unless marked `mutating`.
//   Fix:
struct Logbook {
    var entries: [String] = []
    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}
var logbook = Logbook()
logbook.add("day 10: teleporter incident")
print("Report 3 fix:", logbook.entries)

// Report 4 — the struct line does NOT compile, the class line does.
//   snapshot.oxygen = 40  -> error: cannot assign to property: 'snapshot' is a 'let' constant
//   pod.chargeLevel = 10  -> OK
//   Rule: `let` on a struct freezes the whole value, including every property.
//         `let` on a class freezes only the reference (you can't point it at another pod),
//         the object it points to stays mutable.
//   Fix: `var` for the struct.
var dana = CrewSnapshot.rookie(named: "Dana")
dana.oxygen = 40
let podC = TeleportPod(id: "C", chargeLevel: 50)
podC.chargeLevel = 10
print("Report 4 fix:", dana.oxygen, podC.chargeLevel)   // 40 10


// MARK: Level 7 · Sealing the Black Box

final class FlightRecorder {
    // private: nothing outside the class can replace, clear or append to the list directly
    private var entries: [String] = []

    // private(set): outside code can read isSealed but can't write it, so it can't be un-sealed
    public private(set) var isSealed = false

    // public: anyone can read the count; it's computed, so it can't be set
    public var entryCount: Int { entries.count }

    // public: anyone can read the transcript; it's a formatted copy, not the list itself
    public var transcript: String { formatted(prefix: "") }

    // public: the only way in; refuses after sealing
    @discardableResult
    public func add(_ entry: String) -> Bool {
        guard !isSealed else { return false }
        entries.append(entry)
        return true
    }

    // public: one-way switch, there is no unseal
    public func seal() {
        isSealed = true
    }

    // fileprivate: hidden from other files, but auditTranscript below (same file) may use it
    fileprivate func formatted(prefix: String) -> String {
        var result = ""
        for (i, entry) in entries.enumerated() {
            result += "\(prefix)\(i + 1). \(entry)\n"
        }
        return result
    }
}

func auditTranscript(of recorder: FlightRecorder) -> String {
    "AUDIT (sealed: \(recorder.isSealed))\n" + recorder.formatted(prefix: "[audit] ")
}

let recorder = FlightRecorder()
recorder.add("Teleporter online")
recorder.add("Crew transfer reported")
recorder.seal()
print("Add after seal accepted:", recorder.add("Rewrite history"))   // false
print("Entries:", recorder.entryCount)                                 // 2
print(recorder.transcript)
print(auditTranscript(of: recorder))

// Breaking it from outside:
// recorder.entries = []
//   error: 'entries' is inaccessible due to 'private' protection level
// recorder.isSealed = false
//   error: cannot assign to property: 'isSealed' setter is inaccessible


// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?
    Structs get an automatic memberwise init. Classes don't, because they can
    be subclassed and Swift can't know how the whole hierarchy should be set up,
    so every stored property must be initialized in an init you write.

 2. What does `mutating` do to self, and why do classes never need it?
    In a struct method `self` is a constant copy. `mutating` makes `self` inout:
    the method may change properties or replace self entirely (reviveInMedbay).
    A class method works through a reference, so it can always change the object.

 3. In Report 4 both values are `let`. What does `let` freeze?
    Struct: the whole value, every property inside it.
    Class: only the reference — you can't point it at another object, but the
    object's var properties can still change.

 4. Why must a lazy property be var? When does lazy change behaviour?
    Its value is set after init, on first access, so it changes from "empty" to
    a value — a let can't do that.
    Behaviour changes when building it has side effects: fullDiagnostics prints
    "Running full scan..." only if and when it's read, and it captures the state
    at that moment, not at init.

 5. private vs fileprivate in FlightRecorder:
    formatted(prefix:) must be used by auditTranscript, a free function outside
    the class. private would hide it from that function; fileprivate allows it
    while still hiding it from other files.
*/
