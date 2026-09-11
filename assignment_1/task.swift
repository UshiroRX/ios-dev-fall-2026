
// Assignment 1: Your Life Story in Swift

// Step 1: Personal Information

let firstName: String = "Muslik"
let lastName: String = "Olegovich"
let birthYear: Int = 2005

// Bonus
let currentYear: Int = 2026
let age: Int = currentYear - birthYear

let isStudent: Bool = true
let height: Double = 1.78

let university: String = "KBTU"
let major: String = "Information Technologies"
let languagesSpoken: Int = 3
let hasDriverLicense: Bool = true
let gpa: Double = 3.9


// Step 2: Hobbies and Interests

let hobby: String = "gym"
let numberOfHobbies: Int = 3
let favoriteNumber: Int = 7
let isHobbyCreative: Bool = true

let favoriteFood: String = "pelmeni"
let favoriteMovie: String = "F**** club"
let hoursOfCodingPerWeek: Double = 67
let playsMusicalInstrument: Bool = false


// Step 3: Summary (string interpolation)

let studentText = isStudent ? "I am currently a student" : "I am not a student right now"
let creativeText = isHobbyCreative ? "which is a creative hobby" : "which is not really a creative hobby"
let licenseText = hasDriverLicense ? "I have a driver's license" : "I don't have a driver's license yet"
let musicText = playsMusicalInstrument ? "I play a musical instrument" : "I don't play any instruments"


var lifeStory: String = "My name is \(firstName) \(lastName). I am \(age) years old, born in \(birthYear). \(studentText). I am \(height) meters tall."

lifeStory += " I study \(major) at \(university), I speak \(languagesSpoken) languages, and my GPA is \(gpa). \(licenseText)."

lifeStory += " I enjoy \(hobby), \(creativeText). I have \(numberOfHobbies) hobbies in total, and my favorite number is \(favoriteNumber)."

lifeStory += " My favorite food is \(favoriteFood), my favorite movie is \(favoriteMovie), and I code about \(hoursOfCodingPerWeek) hours per week. \(musicText)."


// Bonus: futureGoals + emoji

let futureGoals: String = "In the future, I want to become a Professional Vibecoder."


let 🐱: String = "a cat named Chmonya"
let 🌍: Int = 3
let 🇯🇵: String = "going to Japan"

let myMood: String = "😎"
let favoriteEmoji: String = "🔥"

lifeStory += " " + futureGoals
lifeStory += " I have \(🐱), I have visited \(🌍) countries, and my dream is to \(🇯🇵). My mood today: \(myMood) \(favoriteEmoji)"


// Step 4: Print

print(lifeStory)
