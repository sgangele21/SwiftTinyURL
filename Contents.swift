
/*: text
 # Creating a Mini TinyURL
 ## Basic Idea
 This is basically creating a "Bijective Function" which says;
 > If you can perform the function `f(x) = y`, then `f(y) = x`.
 
 You have to some how figure out how to create this bijective function.
 
 ## Links
 * [Converting base 10 to base X](https://www.youtube.com/watch?v=aM68oVTf1BM)
 * [Converting base X to base 10](http://www.mathsisfun.com/base-conversion-method.html)
*/
import Darwin
import UIKit

// Utilities --------------------------

func incrementer() -> (() -> Int) {
    var num = 124 // Arbitrary starting point
    func increment() -> Int {
        num += 1
        return num
    }
    return increment
}

extension Int {
    
    static func pow(num1: Int, num2: Int) -> Int {
        return Int(Darwin.pow(Double(num1), Double(num2)))
    }
}

var database: [Int : String] = [ : ]

// Classic procedure of converting base 10 to base X numbers
// First find out the highest exponent of Base X you can go in order before going over the base 10 number
// Use this number to perform a base divison where you divide the base10Num by the BaseX^exponent number
// Find the value of division, find remainder, and use this remainder as your next division
// So you now divide your remainder by the baseX^exponent number - 1. Continue this until you exponent number is 0
// https://www.youtube.com/watch?v=aM68oVTf1BM
func convertBaseTen(from baseTenNum: Int, toBase baseXNum: Int) -> [Int]{
    var largestBase = 0
    while(Int.pow(num1: baseTenNum, num2: largestBase + 1) <= baseTenNum) {
        largestBase += 1
    }
    var remainder = baseTenNum
    var digits: [Int] = []
    
    for i in (0...largestBase).reversed() {
        // BaseXnum^i
        let baseXValue = Int.pow(num1: baseXNum, num2: i)
        // Calculate the digit
        var temp = remainder / baseXValue
        // Append digit
        digits.append(temp)
        // Find remainder, and set reminder for next iteration
        remainder = remainder % baseXValue
    }
    return digits
}

// This is a classic procedure of taking each digit starting from the right
// Multiplying that digit by it's base^0..... Then add that with the next digit * base^1
// And so on
// http://www.mathsisfun.com/base-conversion-method.html
func convertToBaseTen(from baseXDigits: [Int], base: Int) -> Int {
    var exponent = baseXDigits.count - 1
    var totalNum = 0
    for num in baseXDigits {
        // We have our number, now we need to convert this number from Base 62 -> Base 10
        totalNum += num * Int.pow(num1: base, num2: exponent)
        exponent -= 1
        
    }
    
    return totalNum
}

// TinyURL Code --------------------------

let characters: [Character] = [Character]("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")

var autoIncrementedID = incrementer()

func encode(regularURL: String, baseEncodedURL: String) -> String {
    
    let baseURL = "http://tinyurl.com/"
    let id = autoIncrementedID()
    print("ID: \(id)")
    database[id] = regularURL
    // Start the process of converting the ID from base 10 to base 62 to get an index from the array
    
    // Find out what is the largest size you can divide by in base 62
    let digits = convertBaseTen(from: id, toBase: characters.count)
    
    // Map
    var strID = ""
    for num in digits {
        strID.append(characters[num])
    }
    return baseURL + "\(strID)"
    
}

func decode(tinyURL: String) -> String {
    
    guard let strID = tinyURL.split(separator: "/").last else { return "Screwed Up" }
    
    // We have the letter, all we need to do is map these letters to a number.
    // This number will be our ID in our "Database"
    var digits: [Int] = []
    for char in strID {
        let index = characters.index(of: char)!
        digits.append(index)
    }
    
    let id = convertToBaseTen(from: digits, base: characters.count)
    return database[id]!
    
}

// Tests --------------------------

let baseURL = "http://tinyurl.com/"
let url = "https://leetcode.com/problems/design-tinyurl"

let encodedURL = encode(regularURL: url, baseEncodedURL: baseURL)
let decodedURL = decode(tinyURL: encodedURL)

print(encodedURL)
print(decodedURL)

assert(url == decodedURL, "Something is wrong with encoding / decoding!")
