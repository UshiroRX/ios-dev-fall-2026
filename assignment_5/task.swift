// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Power Cell

// Why a class and not a struct here?  -> A drone holds its cell by reference, so spending
// through the drone must drain that one battery, not a copy of it.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = min(max(charge, 0), 100)
    }

    func level() -> Int {
        charge
    }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, amount <= charge else { return false }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        guard amount > 0 else { return }
        charge = min(charge + amount, 100)
    }
}

let testCell = PowerCell(charge: 150)
print("Cell clamped:", testCell.level())                                       // 100
print("Spend 30:", testCell.spend(30), "Spend -5:", testCell.spend(-5), "Spend 500:", testCell.spend(500))
testCell.recharge(by: 90)
print("After recharge:", testCell.level())                                     // 100

// Encapsulation proof (leave this commented, with the compiler error):
// testCell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level


// MARK: Level 2 · The Fleet

// 2.1
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }

    var statusLine: String {
        "\(id): \(cell.level())% \(cell.level().powerBar)"
    }

    func performTask() -> Int { 0 }

    // final: subclasses change the cost and the work, but no subclass can
    // replace the ritual and skip paying for its work.
    final func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

// 2.2
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 40 }

    func weldSeam() -> String {
        "\(id): seam welded"
    }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }
    override func performTask() -> Int { 15 }
    override var statusLine: String { super.statusLine + " [scanner]" }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }
    override func performTask() -> Int { 25 }
}

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":  return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo":   return CargoDrone(id: id, cell: cell)
    default:        return nil
    }
}

var builtFleet: [Drone] = []
for record in fleetData {
    guard let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) else {
        print("Warning: unknown drone kind '\(record.kind)' (\(record.id)), skipped")
        continue
    }
    builtFleet.append(drone)
}
let fleet = builtFleet
print("Fleet:", fleet.count, "drones")


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var total = 0
    for _ in 0..<rounds {
        for drone in fleet {
            total += drone.runOnce()
        }
    }
    return total
}

let A = runShift(fleet, rounds: 3)

var remainingCharge = 0
var readyCount = 0
for drone in fleet {
    print(drone.statusLine)
    remainingCharge += drone.cell.level()
    if drone.cell.level() >= drone.powerCost {
        readyCount += 1
    }
}
print("Ready for one more task:", readyCount)

let B = remainingCharge
let C = readyCount
print("A =", A, "B =", B, "C =", C)


// MARK: Level 4 · Diagnostics

// 4.1
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// 4.2
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// Why does Drone implement recharge(by:) without `mutating`?  -> A class is a reference type:
// its methods change the object through the reference, `self` itself never changes,
// so `mutating` has no meaning for classes.
extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }
    var statusCode: Int { healthCode(forCharge: cell.level()) }

    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String { id }
    var statusCode: Int { healthCode(forCharge: chargeLevel) }

    mutating func recharge(by amount: Int) {
        guard amount > 0 else { return }
        chargeLevel = min(chargeLevel + amount, 100)
    }
}

var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(id: record.id, chargeLevel: record.charge))
}

var spareSensor = SensorModule(id: "spare", chargeLevel: 10)
spareSensor.recharge(by: 50)
print("Spare sensor:", spareSensor.chargeLevel, "code", spareSensor.statusCode)   // 60 code 0

// 4.3
// Why could [Drone] never have held the sensors?  -> SensorModule is a struct that isn't
// a Drone subclass (structs can't inherit at all); only a shared protocol unites them.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var report = "=== DIAGNOSTICS ===\n"
    for component in components {
        report += component.diagnose() + "\n"
    }
    return report
}

var components: [Diagnosable] = []
for drone in fleet { components.append(drone) }
for sensor in sensors { components.append(sensor) }
print(diagnosticsReport(components))


// MARK: Level 5 · Shared Behaviour

// 5.1 · default diagnose() + the single home of the Health Rule
extension Diagnosable {
    func diagnose() -> String {
        "\(componentID): code \(statusCode)"
    }

    // The Health Rule — the only place in the file with these thresholds.
    func healthCode(forCharge charge: Int) -> Int {
        if charge < 20 { return 2 }
        if charge < 50 { return 1 }
        return 0
    }
}

// 5.2 · the beacon you cannot edit
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var statusCode: Int { healthCode(forCharge: signalStrength) }

    func diagnose() -> String {
        "[LEGACY HW] \(name): signal \(signalStrength), code \(statusCode)"
    }
}

components.append(beacon)
print(diagnosticsReport(components))

var statusSum = 0
for component in components {
    statusSum += component.statusCode
}
let D = statusSum
print("D =", D)

// 5.3
extension Int {
    var powerBar: String {
        let filled = Swift.min(Swift.max(self / 10, 0), 10)
        var bar = ""
        for i in 0..<10 {
            bar += i < filled ? "#" : "."
        }
        return bar
    }
}

print(42.powerBar)     // ####......
print((-5).powerBar)   // ..........
print(250.powerBar)    // ##########


// MARK: Level 6 · Incident Reports

/*
// Report 1
class PatchDrone: Drone {
    func performTask() -> Int {
        return 30
    }
}

// Report 2
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int {
        return 999
    }
}

// Report 3
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
print(first.weldSeam())

// Report 4
protocol Labelled {
    var componentID: String { get }
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())
*/

// Report 1 — does NOT compile.
//   Expected: a drone that produces 30.
//   error: overriding declaration requires an 'override' keyword
//   Rule: replacing a superclass method must be marked `override`, so it can't happen by accident.
//   Fix:
class PatchDrone: Drone {
    override func performTask() -> Int { 30 }
}
print("Report 1 fix:", PatchDrone(id: "P-1", cell: PowerCell(charge: 100)).runOnce())   // 30

// Report 2 — does NOT compile.
//   Expected: a welder that produces 999 for free.
//   error: inheritance from a final class 'WelderDrone'
//   error: instance method overrides a 'final' instance method
//   Rule: `final` forbids subclassing (class) and overriding (method). That's exactly the
//         protection: nobody can bypass the power check in runOnce().
//   Fix: subclass Drone and change only the allowed parts (cost / work), not the ritual.

// Report 3 — does NOT compile.
//   error: value of type 'Drone' has no member 'weldSeam'
//   Rule: the compiler only allows what the static type (Drone) has, even if the object is a welder.
//   Fix: conditional cast. as? returns an optional because the object might not be that type.
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let firstDrone = reportFleet[0]
if let welder = firstDrone as? WelderDrone {
    print("Report 3 fix:", welder.weldSeam())
}

// Report 4 — compiles, lies: prints "generic component".
//   Rule: label() is not a protocol requirement, it only lives in the extension.
//         Such methods are dispatched statically by the variable's type ([Labelled]),
//         so the extension version runs, and Thruster's own label() is ignored.
//   Fix: declare label() in the protocol — then it's dynamically dispatched.
protocol Labelled {
    var componentID: String { get }
    func label() -> String              // <- the one line that changes the output
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print("Report 4 fix:", parts[0].label())   // thruster T-1


// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` requirement without the keyword?
    `mutating` means "this method may change self". A struct is a value, so
    changing a property changes self — it must be marked. A class method
    changes the object behind the reference; the reference (self) stays the
    same, so there's nothing to mark.

 2. Inheritance vs protocols:
    Inheritance can share stored state and real implementation with override
    and super (Drone's id, cell and runOnce come for free in every subclass).
    Protocols can unite unrelated types — classes, structs, even a type we
    can't edit (SensorModule, LegacyBeacon) — which inheritance can't.

 3. What does `final` prevent, and what did it protect in runOnce()?
    final on a method forbids overriding it; on a class, forbids subclassing.
    In runOnce() it guarantees every drone pays powerCost before working —
    no subclass can replace the ritual and work for free (Report 2).

 4. In Report 4, why did the extension's method win?
    label() wasn't a requirement of the protocol, only an extension method.
    Those are chosen at compile time by the declared type (Labelled), not by
    the real object, so the struct's own label() is never looked up.
*/
