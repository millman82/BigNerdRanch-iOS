import UIKit

var str = "Hello, playground"
str = "Hello, Swift"
let constStr = str

// Specifying types
var nextYear: Int
var bodyTemp: Float
var hasPet: Bool

// Collection types
var arrayOfInts: [Int]
var dictionaryOfCapitalsByCountry: [String:String]
var winningLotteryNumbers: Set<Int>

// Literals and subscripting
let number = 42
let fmStation = 91.1
let countingUp = ["one", "two"]
let secondElement = countingUp[1]
let nameByParkingSpace = [13: "Alice", 27: "Bob"]

// Initializers
let emptyString = String()
let emptyArrayOfInts = [Int]()
let emptySetOfFloats = Set<Float>()
let defaultNumber = Int()
let defaultBool = Bool()
let meaningOfLife = String(number)
let availableRooms = Set([205, 411, 412])
let defaultFloat = Float()
let floatFromLiteral = Float(3.14)
let easyPi = 3.14
let floatFromDouble = Float(easyPi)
let floatingPi: Float = 3.14

// Properties
countingUp.count
emptyString.isEmpty

// Instance methods
var countingUpAgain = ["one", "two"]
countingUpAgain.append("three")

// Optionals
var reading1: Float?
var reading2: Float?
var reading3: Float?
reading1 = 9.8
reading2 = 9.2
reading3 = 9.7
// forced unwrapping: let avgReading = (reading1! + reading2! + reading3!) / 3
if let r1 = reading1,
    let r2 = reading2,
    let r3 = reading3 {
        let avgReading = (r1 + r2 + r3) / 3
} else {
    let errorString = "Instrument reported a reading that was nil."
}

if let space13Assignee = nameByParkingSpace[13] {
    print("Key 13 is assigned in the dictionary!")
}
let space42Assignee: String? = nameByParkingSpace[42]

// Loops and String Interpolation
let range = 0..<countingUp.count
for i in range {
    let string = countingUp[i]
    print(string)
}

for string in countingUpAgain {
    print(string)
}

for (i, string) in countingUp.enumerated() {
    print("\(i): \(string)")
}

for (space, name) in nameByParkingSpace {
    let permit = "Space \(space): \(name)"
    print(permit)
}

// Enumerations and the Switch Statement
enum PieType: Int {
    case apple = 0
    case cherry
    case pecan
}

let favoritePie = PieType.apple
let cherryPie: PieType = .cherry

let name: String
switch favoritePie {
case .apple:
    name = "Apple"
case .cherry:
    name = "Cherry"
case .pecan:
    name = "Pecan"
}

let pieRawValue = PieType.pecan.rawValue

if let pieType = PieType(rawValue: pieRawValue) {
    print("Valid pie type: \(pieType)")
}

let macOSVersion: Int = 17
switch macOSVersion {
case 0...8:
    print("A big cat")
case 9:
    print("Mavericks")
case 10:
    print("Yosemite")
case 11:
    print("El Capitan")
case 12:
    print("Sierra")
case 13:
    print("High Sierra")
case 14:
    print("Mojave")
case 15:
    print("Catalina")
default:
    print("Greetings, people of the future! What's new in 10.\(macOSVersion)?")
}

