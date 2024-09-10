//
//  File.swift
//  
//
//  Created by Trang Do on 9/9/24.
//

import Foundation
class Parser {
    private let tokens : [Token]
    private var current : Int = 0
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    func expression()-> Expr {
        return equality()
    }
    
    func equality() -> Expr {
        var expr = comparison()
        
        while (match([.bangEqual, .equalEqual])) {
            let op = previous()
            let right = comparison()
            expr = Expr.Binary(left: expr, op: op, right: right)
        }

        return expr;
    }
    
    func comparison() -> Expr {
        var expr = term()
        
        while (match([.greater, .greaterEqual, .less, .lessEqual])) {
            let op = previous()
            let right = term()
            expr =  Expr.Binary(left: expr, op: op, right: right)
        }
        return expr
    }
    
    func term() -> Expr {
        var expr = factor()
        
        while (match([.minus, .plus])) {
            let op = previous()
            let right = term()
            expr =  Expr.Binary(left: expr, op: op, right: right)
        }
        return expr
    }
    
    func factor() -> Expr {
        var expr = unary()
        
        while (match([.slash, .star])) {
            let op = previous()
            let right = term()
            expr =  Expr.Binary(left: expr, op: op, right: right)
        }
        return expr
    }
    
    func unary() -> Expr{
        if (match([.bang, .minus])) {
            let op = previous()
            let right = unary()
            return Expr.Unary(op, right)
        }
        return primary()
    }
    
    func primary() -> Expr{
        if match([.False]) {
            return Expr.Literal(false)
        }
        if match([.True]) {
            return Expr.Literal(true)
        }
        if match([.Nil]) {
            return Expr.Literal(nil)
        }
        if match([.number, .string]) {
            return Expr.Literal(previous().literal)
        }
        
        if match([.leftParen]) {
            let expr = expression()
            consume(.rightParen, "Expect ')' after expression.")
            return Expr.Grouping(expr)
        }
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
    
    
}
