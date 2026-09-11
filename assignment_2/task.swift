// Assignment 2: Working with Collections in Swift

// Easy Tasks

// 1. Array Creation and Access
let fruits: [String] = ["apple", "banana", "orange", "mango", "kiwi"]
print("Third fruit:", fruits[2])                         // orange


// 2. Set Creation and Manipulation
var favoriteNumbers: Set<Int> = [3, 7, 13, 21]
favoriteNumbers.insert(42)
print("Updated favorite numbers:", favoriteNumbers)


// 3. Dictionary Creation and Access
let languageReleaseYears: [String: Int] = [
    "Swift": 2014,
    "Python": 1991,
    "Kotlin": 2011
]
print("Swift release year:", languageReleaseYears["Swift"] ?? 0)   // 2014


// 4. Array Element Update
var colors: [String] = ["red", "green", "blue", "yellow"]
colors[1] = "purple"
print("Updated colors:", colors)                          // ["red", "purple", "blue", "yellow"]


// Medium Tasks

// 1. Set Intersection
let firstSet: Set<Int> = [1, 2, 3, 4]
let secondSet: Set<Int> = [3, 4, 5, 6]
let intersectionSet = firstSet.intersection(secondSet)
print("Intersection:", intersectionSet)               


// 2. Dictionary Update
var studentScores: [String: Int] = [
    "Alice": 85,
    "Bob": 72,
    "Charlie": 90
]
studentScores.updateValue(95, forKey: "Bob")
print("Updated scores:", studentScores)


// 3. Array Merge
let firstArray: [String] = ["apple", "banana"]
let secondArray: [String] = ["cherry", "date"]
let mergedArray = firstArray + secondArray
print("Merged array:", mergedArray)                       // ["apple", "banana", "cherry", "date"]


// Hard Tasks

// 1. Dictionary Key Addition
var countryPopulations: [String: Int] = [
    "China": 1_410_000_000,
    "India": 1_430_000_000,
    "USA": 335_000_000
]
countryPopulations["Japan"] = 124_000_000
print("Updated populations:", countryPopulations)


// 2. Set Union and Subtract
let setOne: Set<String> = ["cat", "dog"]
let setTwo: Set<String> = ["dog", "mouse"]
let unionSet = setOne.union(setTwo)                       // ["cat", "dog", "mouse"]
let finalSet = unionSet.subtracting(setTwo)               // убираем "dog" и "mouse"
print("Final set:", finalSet)                             // ["cat"]


// 3. Nested Collection
let studentGrades: [String: [Int]] = [
    "Alice": [90, 85, 78],
    "Bob": [70, 88, 95],
    "Charlie": [82, 91, 67]
]
// studentGrades["Bob"] gives [Int]? (Optional type)
let bobSecondGrade = studentGrades["Bob"]?[1] ?? 0
print("Bob's second grade:", bobSecondGrade)              // 88
