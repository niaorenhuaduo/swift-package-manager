/*
 This source file is part of the Swift.org open source project

 Copyright 2015 - 2016 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

/// Check if the given code unit needs shell escaping.
//
/// - Parameters:
///     - codeUnit: The code unit to be checked.
///
/// - Returns: True if shell escaping is not needed.
private func inShellWhitelist(_ codeUnit: UInt8) -> Bool {
    switch codeUnit {
        case UInt8(ascii: "a")...UInt8(ascii: "z"),
             UInt8(ascii: "A")...UInt8(ascii: "Z"),
             UInt8(ascii: "0")...UInt8(ascii: "9"),
             UInt8(ascii: "-"),
             UInt8(ascii: "_"),
             UInt8(ascii: "/"),
             UInt8(ascii: ":"),
             UInt8(ascii: "@"),
             UInt8(ascii: "%"),
             UInt8(ascii: "+"),
             UInt8(ascii: "="),
             UInt8(ascii: "."),
             UInt8(ascii: ","):
        return true
    default:
        return false
    }
}

public extension String {

    /// Creates a shell escaped string. If the string does not need escaping, returns the original string.
    /// Otherwise escapes using single quotes. For eg: hello -> hello, hello$world -> 'hello$world', input A -> 'input A'
    ///
    /// - Returns: Shell escaped string.
    public func shellEscaped() -> String {

        // If all the characters in the string are in whitelist then no need to escape.
        guard let pos = utf8.index(where: { !inShellWhitelist($0) }) else {
            return self
        }

        // If there are no single quotes then we can just wrap the string around single quotes.
        guard let singleQuotePos = utf8[pos..<utf8.endIndex].index(of: UInt8(ascii: "'")) else {
            return "'" + self + "'"
        }

        // Otherwise iterate and escape all the single quotes.
        var newString = "'" + String(utf8[utf8.startIndex..<singleQuotePos])!

        for char in utf8[singleQuotePos..<utf8.endIndex] {
            if char == UInt8(ascii: "'") {
                newString += "'\\''"
            } else {
                newString += String(UnicodeScalar(char))
            }
        }

        newString += "'"

        return newString
    }

    /// Shell escapes the current string. This method is mutating version of shellEscaped().
    public mutating func shellEscape() {
        self = shellEscaped()
    }
}

extension String {
    /// Repeats self n times. If n is less than zero, returns the same string.
    public func repeating(n: Int) -> String {
        guard n >= 0 else { return self }
        var str = ""
        for _ in 0..<n {
            str = str + self
        }
        return str
    }
}
