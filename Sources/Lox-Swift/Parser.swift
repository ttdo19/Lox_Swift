//
//  File.swift
//  
//
//  Created by Trang Do on 9/9/24.
//

enum ParseError: Error {
    case token
}

import Foundation
class Parser {
    private let tokens : [Token]
    private var current : Int = 0
    private let errorReporting: ErrorReporting
    
    init(tokens: [Token], errorReporting: ErrorReporting) {
        self.tokens = tokens
        self.errorReporting = errorReporting
    }
    
    func parse() -> Expr? {
        do {
            return try expression()
        } catch {
            return nil
        }
    }
    
    func expression() throws -> Expr {
        return try equality()
    }
    
    func equality() throws ->  Expr {
        var expr = try comparison()
        
        while (match([.bangEqual, .equalEqual])) {
            let op = previous()
            let right = try comparison()
            expr = Expr.Binary(left: expr, op: op, right: right)
        }

        return expr;
    }
    
    func comparison() throws -> Expr {
        var expr = try term()
        
        while (match([.greater, .greaterEqual, .less, .lessEqual])) {
            let op = previous()
            let right = try term()
            expr =  Expr.Binary(left: expr, op: op, right: right)
        }
        return expr
    }
    
    func term() throws -> Expr {
        var expr = try factor()
        
        while (match([.minus, .plus])) {
            let op = previous()
            let right = try term()
            expr =  Expr.Binary(left: expr, op: op, right: right)
        }
        return expr
    }
    
    func factor() throws -> Expr {
        var expr = try unary()
        
        while (match([.slash, .star])) {
            let op = previous()
            let right = try term()
            expr =  Expr.Binary(left: expr, op: op, right: right)
        }
        return expr
    }
    
    func unary() throws -> Expr{
        if (match([.bang, .minus])) {
            let op = previous()
            let right = try unary()
            return Expr.Unary(op: op, right: right)
        }
        return try primary()
    }
    
    func primary() throws -> Expr{
        if match([.False]) {
            return Expr.Literal(value: false)
        }
        if match([.True]) {
            return Expr.Literal(value: true)
        }
        if match([.Nil]) {
            return Expr.Literal(value: nil)
        }
        if match([.number, .string]) {
            return Expr.Literal(value: previous().literal)
        }
        
        if match([.leftParen]) {
            let expr = try expression()
            try consume(type: .rightParen, message: "Expect ')' after expression.")
            return Expr.Grouping(expression: expr)
        }
        throw error(token: peek(), message: "Expect expression")
    }
    
    func match(_ tokenTypes: [TokenType]) -> Bool {
        for tokenType in tokenTypes {
            if (check(tokenType)) {
                advance()
                return true
            }
        }
        return false
    }
    
    @discardableResult
    func consume(type: TokenType, message: String) throws -> Token {
        if (check(type)) {
            return advance()
        }
        throw error(token: peek(), message: message)
    }
    
    func check(_ tokenType: TokenType) -> Bool {
        if isAtEnd() {
            return false
        }
        return peek().type == tokenType
     }
    
    @discardableResult
    func advance() -> Token{
        if !isAtEnd() {
            current += 1
        }
        return previous()
    }
    
    func isAtEnd() -> Bool {
        return peek().type == .eof
    }

    func peek() -> Token {
        return tokens[current]
    }

    func previous() -> Token {
        return tokens[current-1]
    }
    
    func error(token: Token, message: String) -> ParseError {
        errorReporting.error(at: token, message: message)
        return ParseError.token
    }
    
    func synchronize() {
        advance()
        
        while !isAtEnd() {
            if previous().type == .semicolon {
                return
            }
            
            switch peek().type {
            case .Class, .Fun, .Var, .For, .If, .While, .Print, .Return:
                return
            default:
                break
            }
            
            advance()
        }
    }
}
