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
    
    func parse() -> [Stmt] {
        var statements = [Stmt]()
        while (!isAtEnd()) {
            if let declaration = declaration() {
                statements.append(declaration)
            }
        }
        return statements
    }
    
    func expression() throws -> Expr {
        return try assignment()
    }
    
    func declaration() -> Stmt? {
        do {
            if match([.Var]) {
                return try varDeclaration()
            }
            return try statement()
        } catch {
            synchronize()
            return nil
        }
    }
    
    func statement() throws -> Stmt {
        if (match([.For])) {
            return try forStatement()
        }
        if (match([.If])) {
            return try ifStatement()
        }
        if (match([.Print])) {
            return try printStatement()
        }
        if match([.While]) {
            return try whileStatement()
        }
        if (match([.leftBrace])) {
            return try Stmt.Block(statements: block())
        }
        return try expressionStatement()
    }
    
    func forStatement() throws -> Stmt {
        try consume(type: .leftParen, message: "Expect '(' after 'for'.")
        
        var initializer : Stmt?
        if (match([.semicolon])) {
            initializer = nil
        } else if (match([.Var])) {
            initializer = try varDeclaration()
        } else {
            initializer = try expressionStatement()
        }
        
        var condition: Expr? = nil
        if (!check(.semicolon)) {
            condition = try expression()
        }
        try consume(type: .semicolon, message: "Expect ';' after loop condition.")
        
        var increment: Expr? = nil
        if (!check(.rightParen)) {
            increment = try expression()
        }
        try consume(type: .rightParen, message: "Expect ')' after for clauses.")
        
        var body = try statement()
        
        if let increment = increment {
            body = Stmt.Block(statements: [body, Stmt.Expression(expression: increment)])
        }
        
        if (condition == nil) {condition = Expr.Literal(value: true)}
        body = Stmt.While(condition: condition!, body: body)
        
        if let initializer = initializer {
            body = Stmt.Block(statements: [initializer, body])
        }
        return body
    }
    
    func whileStatement() throws-> Stmt {
        try consume(type: .leftParen, message: "Expect '(' after 'while'.")
        let condition = try expression()
        try consume(type: .rightParen, message: "Expect ')' after condition.")
        let body = try statement()
        
        return Stmt.While(condition: condition, body: body)
    }
    
    func ifStatement() throws -> Stmt {
        try consume(type: .leftParen, message: "Expect '(' after 'if'.")
        let condition = try expression()
        try consume(type: .rightParen, message: "Expect ')' after if condition.")
        
        let thenBranch = try statement()
        var elseBranch : Stmt? = nil
        if match([.Else]) {
            elseBranch = try statement()
        }
        return Stmt.If(condition: condition, thenBranch: thenBranch, elseBranch: elseBranch)
    }
    
    func printStatement() throws -> Stmt {
        let value = try expression()
        try consume(type: .semicolon, message: "Expect ';' after value.")
        return Stmt.Print(expression: value)
    }
    
    func varDeclaration() throws -> Stmt {
        let name = try consume(type: .identifier, message: "Expect variable name.")
        var initializer : Expr? = nil
        if match([.equal]) {
            initializer = try expression()
        }
        try consume(type: .semicolon, message: "Expect ';' after variable declaration.")
        return Stmt.Var(name: name, initializer: initializer)
    }
    
    func expressionStatement() throws-> Stmt {
        let expr = try expression()
        try consume(type: .semicolon, message: "Expect ';' after expression.")
        return Stmt.Expression(expression: expr)
    }
    
    func block() throws ->  [Stmt] {
        var statements = [Stmt]()
        
        while (!check(.rightBrace) && !isAtEnd()) {
            if let declaration = declaration() {
                statements.append(declaration)
            }
        }
        
        try consume(type: .rightBrace, message: "Expect '}' after block.")
        return statements
    }
    
    func assignment() throws -> Expr {
        let expr = try or()
        
        if (match([.equal])) {
            let equals = previous()
            let value = try assignment()
            
            if let expr = expr as? Expr.Variable {
                let name = expr.name
                return Expr.Assign(name: name, value: value)
            } 
            errorReporting.error(at: equals, message: "Invalid assignment target.")
        }
        return expr
    }
    
    func or() throws -> Expr {
        var expr = try and()
        
        while (match([.Or])) {
            let op = previous()
            let right = try and()
            expr = Expr.Logical(left: expr, op: op, right: right)
        }
        return expr
    }
    
    func and() throws -> Expr {
        var expr = try equality()
        
        while (match([.And])) {
            let op = previous()
            let right = try equality()
            expr = Expr.Logical(left: expr, op: op, right: right)
        }
        return expr
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
        if match([.identifier]) {
            return Expr.Variable(name: previous())
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
