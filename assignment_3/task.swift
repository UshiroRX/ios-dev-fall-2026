// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · Decoding Telemetry

// 1.1
func parseReading(_ raw: String) -> Reading? {
    guard let parts = splitOnce(raw, by: ":"),
          !parts.0.isEmpty,
          let value = Int(parts.1),
          value >= 0 || parts.0 == "TEMP"
          else {
              return nil }
    return (sensor: parts.0, value: value)
}

print(parseReading("O2:87") as Any)      // (sensor: "O2", value: 87)
print(parseReading("TEMP:-12") as Any)   // (sensor: "TEMP", value: -12)
print(parseReading("RAD:-1") as Any)     // nil
print(parseReading(":55") as Any)        // nil

// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount : Int = 0
    
    for line in lines {
        if let check = parseReading(line) {
            valid.append(check)
        } else {
            invalidCount += 1
        }
    }
    
    return (valid, invalidCount)
}

print(parseLog(["O2:1", "bad", "TEMP:-5"]).invalidCount)   // 1
print(parseLog([]).valid.count)                             // 0

let A = parseLog(rawLog).invalidCount
print("A =", A)


// MARK: Level 2 · Analysis

// 2.1
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result : [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    
    for reading in readings {
        result.append(reading.value)
    }
    
    return result
}

let valid = parseLog(rawLog).valid
let o2Readings = select(valid) { $0.sensor == "O2" }
print("O2 readings:", o2Readings)
print("O2 values:", values(of: o2Readings))
print("TEMP values:", values(of: select(valid) { $0.sensor == "TEMP" }))

// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let minValue = values.min(), let maxValue = values.max() else {
        return nil
    }

    var sum = 0
    for v in values {
        sum += v
    }

    let average = Double(sum) / Double(values.count)
    return (min: minValue, max: maxValue, average: average)
}
func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

print(stats(3, 8, 1) as Any)        // (min: 1, max: 8, average: 4.0)
print(stats() as Any)               // nil
print(stats(of: [10, 20]) as Any)   // (min: 10, max: 20, average: 15.0)

let o2Values = values(of: o2Readings)
let B = Int(stats(of: o2Values)?.average ?? 0)
print("B =", B)

// 2.3 · The Closure Ladder (5 sorts, then compare results in code)

// 1. Full syntax: parameter types, return type, return keyword
let sorted1 = valid.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})
// 2. Types inferred from context
let sorted2 = valid.sorted(by: { a, b in return a.value > b.value })
// 3. Implicit return (single expression)
let sorted3 = valid.sorted(by: { a, b in a.value > b.value })
// 4. Shorthand argument names
let sorted4 = valid.sorted(by: { $0.value > $1.value })
// 5. Trailing closure
let sorted5 = valid.sorted { $0.value > $1.value }

// Tuples aren't Equatable, so compare element by element
func sameOrder(_ a: [Reading], _ b: [Reading]) -> Bool {
    guard a.count == b.count else { return false }
    for i in 0..<a.count {
        if a[i].sensor != b[i].sensor || a[i].value != b[i].value {
            return false
        }
    }
    return true
}

let ladderOK = sameOrder(sorted1, sorted2) && sameOrder(sorted1, sorted3)
    && sameOrder(sorted1, sorted4) && sameOrder(sorted1, sorted5)
print("Sorted desc:", values(of: sorted1))
print("All 5 sorts match:", ladderOK)


// MARK: Level 3 · Temperature Stabilization

// 3.1
func heatUp(_ t: Int) -> Int {
    return t + 5
}
func coolDown(_ t: Int) -> Int {
    return t - 3
}
func hold(_ t: Int) -> Int {
    return t
}
func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 {
        return heatUp
    } else if temp > 24 {
        return coolDown
    }
    
    return hold
}

print(heatUp(10), coolDown(30), hold(20))        // 15 27 20
print(chooseProtocol(for: 10)(10))               // 15 (heatUp)
print(chooseProtocol(for: 30)(30))               // 27 (coolDown)
print(chooseProtocol(for: 20)(20))               // 20 (hold)

// 3.2
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var steps = 0
    var temp = start
    
    while !(18...24).contains(temp) && steps < maxSteps {
        steps += 1
        temp = chooseProtocol(for: temp)(temp)
    }
    
    return (temp, steps, (18...24).contains(temp))
    
}

print(runUntilStable(from: 31))                  // (finalTemp: 22, steps: 3, isStable: true)
print(runUntilStable(from: -100, maxSteps: 5))   // (finalTemp: -75, steps: 5, isStable: false)

let tempValues = values(of: select(valid) { $0.sensor == "TEMP" })
let lowestTemp = stats(of: tempValues)?.min ?? 0
let C = runUntilStable(from: lowestTemp).steps
print("C =", C)


// MARK: Level 4 · The Crew

// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

print(oxygenLevel(of: crew[0]))   // Timur: 40
print(oxygenLevel(of: crew[1]))   // Dana: nil (Dock has no tank)
print(oxygenLevel(of: crew[3]))   // Nurlan: nil (no module)

// 4.2
func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data (\(member.module?.name ?? "open space"))"
    }
    if level < 20 {
        return "\(member.name): \(level)% CRITICAL"
    }
    return "\(member.name): \(level)% OK"
}

for member in crew {
    print(status(of: member))
}

// 4.3
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else { return 0 }
    // can't take more than the source has, can't overfill the target
    let moved = max(0, min(amount, source, 100 - target))
    source -= moved
    target += moved
    return moved
}

var testSource = 10
var testTarget = 95
print(transferOxygen(from: &testSource, to: &testTarget, amount: 30))   // 5 (target was almost full)
print(transferOxygen(from: &testSource, to: &testTarget, amount: -4))   // 0 (negative amount)
print(testSource, testTarget)                                           // 5 100

// Tanks are optional: unwrap both safely, then pass their levels as inout
if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    let moved = transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
    print("Transferred \(moved): Lab \(labTank.level)%, Hab \(habTank.level)%")
}

let D = hab.oxygenTank?.level ?? 0
print("D =", D)

// 4.4
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var found: [CrewMember] = []
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        found.append(member)
    }

    let byPriority = found.sorted { $0.priority < $1.priority }
    var result: [String] = []
    for member in byPriority {
        result.append(member.name)
    }
    return result
}

print(evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))   // ["Aigerim", "Timur", "Dana"]
print(evacuationOrder("Nurlan", "Timur", roster: roster))                     // ["Nurlan", "Timur"]


// MARK: Level 5 · The Saboteur's Logbook

/*
func reportOxygen(for member: CrewMember) -> String {
    let tank = member.module!.oxygenTank!
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String {
    var result: String?
    for member in crew {
        if oxygenLevel(of: member)! < 20 {
            result = member.name
        }
    }
    return result!
}
*/

// Problems:
// 1. reportOxygen: `member.module!` — Nurlan has no module (open space),
//    module is nil -> runtime crash.
// 2. reportOxygen: `.oxygenTank!` — Dana is in Dock, which has no tank,
//    oxygenTank is nil -> runtime crash.
// 3. firstCritical: `oxygenLevel(of: member)!` — Dana and Nurlan have no data,
//    the level is nil -> crash on the first such member in the loop.
// 4. firstCritical: LOGIC BUG — the loop never stops, it keeps overwriting
//    `result`, so it returns the LAST critical member, not the first.
//    With the starter data only Aigerim is critical, so it's invisible.
// 5. firstCritical: `return result!` — if nobody is critical, result is nil
//    -> crash. "Nobody is critical" is a normal answer, so it must be String?.
// 6. firstCritical: the signature returns String, which can't express
//    "nobody found" at all — it forces the author into `!`.

func reportOxygen(for member: CrewMember) -> String {
    guard let tank = member.module?.oxygenTank else {
        return "\(member.name): no data"
    }
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name     // stop at the FIRST one
        }
    }
    return nil
}

for member in crew {
    print(reportOxygen(for: member))   // no crash for Dana or Nurlan
}

// Test for the logic bug: two critical members, the first one must win.
// The old code would return "Second" here (and crash on "Lost" before that).
let lost = CrewMember(name: "Lost", role: "Test", priority: 9, module: nil)
let first = CrewMember(name: "First", role: "Test", priority: 9,
                       module: Module(name: "T1", oxygenTank: Tank(level: 5)))
let second = CrewMember(name: "Second", role: "Test", priority: 9,
                        module: Module(name: "T2", oxygenTank: Tank(level: 10)))
let found = firstCritical(in: [lost, first, second])
print("firstCritical:", found ?? "none", "| correct:", found == "First")   // First | true
print("firstCritical (nobody critical):", firstCritical(in: [lost]) ?? "none")   // none


// MARK: Finale · Launch Code

let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var count = 0
    return { level in
        guard level < threshold else { return false }
        count += 1
        print("Alarm #\(count)")
        return true
    }
}

let alarm = makeAlarm(threshold: 20)
print(alarm(12))   // Alarm #1 -> true
print(alarm(40))   // false
print(alarm(5))    // Alarm #2 -> true

let otherAlarm = makeAlarm(threshold: 50)
print(otherAlarm(30))   // Alarm #1 -> true (its own separate counter)


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:
    - The value unwrapped by guard let stays available AFTER the guard, until
      the end of the function. With if let it only exists inside the { }.
    - The else of a guard MUST leave the scope (return/continue/break/throw);
      the compiler checks it. So after a guard you know for sure the check passed.

 2. Why can't you pass [Int] to stats(_ values: Int...)?
    Int... means "any number of separate Int arguments": stats(3, 8, 1).
    Swift packs them into an array only INSIDE the function. From the caller's
    side [Int] is a different type than Int, and Swift has no way to "spread"
    an array into variadic arguments (like *args in Python). That's why the
    logic lives in stats(of: [Int]) and the variadic one just forwards to it.

 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?
    Exclusive access rule: a variable can't be passed as inout twice at the same
    time, because both parameters would write to the same memory.
    It prevents a real bug: source -= moved and target += moved would hit the
    same variable, and the result would depend on write order — oxygen could
    appear from nowhere or vanish, while the function reports a "transfer".

 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?
    ?? needs both sides of the same type: the left side is Int?, so the default
    must be Int. "no data" is a String -> type mismatch.
    Fix: make both sides the same type, e.g.
        let text: String
        if let level = oxygenLevel(of: dana) { text = "\(level)%" } else { text = "no data" }

 5. Full type of chooseProtocol and how to read it:
        (Int) -> (Int) -> Int
    The arrow is right-associative, so it means (Int) -> ((Int) -> Int):
    "a function that takes an Int (the temperature) and returns a function
    that takes an Int and returns an Int" (the protocol to apply).

 Bonus. Where does the alarm counter live after makeAlarm returns?
    `count` is captured by the closure. Since the closure outlives the
    function call, Swift moves `count` out of the stack into a heap-allocated
    box that the closure holds a reference to. It lives as long as the
    closure (`alarm`) lives. Each makeAlarm call creates its own box, so
    `alarm` and `otherAlarm` have independent counters.
*/
