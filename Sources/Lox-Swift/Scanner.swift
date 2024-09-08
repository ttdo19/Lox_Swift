//
//  Scanner.swift
//  Lox
//
//  Created by Trang Do on 9/6/24.
//

import Foundation

class Scanner {
    private let source: String
    private var tokens: [Token] = []
    
    private var start = 0
    private var current = 0
    private var line = 1
    
    private var isAtEnd: Bool {
        current >= source.count
    }
    private let errorReporting: ErrorReporting
    
    init(source: String, errorReporting: ErrorReporting) {
        self.source = source
        self.errorReporting = errorReporting
        
    }
    
    private static let keywords: [String: TokenType] = [
        "and": .And,
        "class": .Class,
        "else": .Else,
        "false": .False,
        "for": .For,
        "fun": .Fun,
        "if": .If,
        "nil": .Nil,
        "or": .Or,
        "print": .Print,
        "return": .Return,
        "super": .Super,
        "this": .This,
        "true": .True,
        "var": .Var,
        "while": .While
    ]
    
    func scanTokens() -> [Token] {
        while (!isAtEnd) {
            // We are at the beginning of the next lexeme.
            start = current;
            scanToken()
        }
        let token = Token(type: .eof, line: line)
        tokens.append(token)
        return tokens
     }
    
    func scanToken() {
        let c = advance()
        switch c {
        case "(":
            addToken(.leftParen)
        case ")":
            addToken(.rightParen)
        case "{":
            addToken(.leftBrace)
        case "}":
            addToken(.rightBrace)
        case ",":
            addToken(.comma)
        case ".":
            addToken(.dot)
        case "-":
            addToken(.minus)
        case "+":
            addToken(.plus)
        case ";":
            addToken(.semicolon)
        case "*":
            addToken(.star)
        case "!":
            addToken(match("=") ? .bangEqual : .bang)
        case "=":
            addToken(match("=") ? .equalEqual : .equal)
        case "<":
            addToken(match("=") ? .lessEqual : .less)
        case ">":
            addToken(match("=") ? .greaterEqual : .greater)
        case "/":
            if (match("/")) {
                // A comment goes until the end of the line.
                while (peek() != "\n" && !isAtEnd) {
                    advance()
                }
            } else {
                addToken(.slash)
            }
        case " ", "\r", "\t":
            // Ignore whitespace.
            break
        case "\n":
            line += 1
        case "\"":
            string()
        default:
            if (isDigit(c)) {
                number()
            } else if (isAlpha(c)) {
                identifier()
            } else {
                errorReporting.error(line, "Unexpected character.")
            }
        }
    }
    
    @discardableResult
    func advance() -> Character {
        let char = source[current]
        current += 1
        return char
    }
                    
    func addToken(_ type: TokenType, _ literal: Any? = nil) {
        let text = String(source[start..<current])
        let token = Token(type: type, lexeme: text, literal: literal, line: line)
        tokens.append(token)
    }
    
    func match(_ expected: Character) -> Bool {
        if (isAtEnd || source[current] != expected) {
            return false
        }
        current += 1
        return true
    }
    
    func peek() -> Character{
        if (isAtEnd) {
            return "\0"
        }
        return source[current]
    }
    
    func string() {
        while (peek() != "\"" && !isAtEnd) {
            if (peek() == "\n") {
                line += 1
            }
            advance()
        }
        if isAtEnd {
            errorReporting.error(line, "Unterminated string.")
            return
        }
        
        // The closing ".
        advance()
        
        // Trim the surrounding quotes.
        let value = String(source[start+1..<current-1])
        addToken(.string, value)
    }
    
    func isDigit(_ c: Character) -> Bool {
        return c >= "0" && c <= "9"
    }
    
    func number() {
        while (isDigit(peek())) {
            advance()
        }
        // Look for a fractional part.
        if (peek() == "." && isDigit(peekNext())) {
            // Consume the "."
            advance()
            while (isDigit(peek())) {
                advance()
            }
        }
        addToken(.number,Double(source[start..<current]));
    }
    
    func peekNext() -> Character {
        guard (current + 1 < source.count) else {
            return "\0"
        }
        return source[current+1]
    }
    
    func identifier() {
        while (isAlphaNumeric(peek())) {
            advance()
        }
        let text = String(source[start..<current])
        let tokenType = Scanner.keywords[text] ?? .identifier
        addToken(tokenType)
    }
    
    func isAlpha(_ c: Character) -> Bool {
        return (c >= "a" && c <= "z") || (c >= "A" && c <= "Z" || c == "_")
    }
    
    func isAlphaNumeric(_ c: Character) -> Bool {
        return isAlpha(c) || isDigit(c)
    }
}

//https://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift/38215613#38215613
extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: Range<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
}
