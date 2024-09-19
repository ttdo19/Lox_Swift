//
//  File.swift
//  
//
//  Created by Trang Do on 9/17/24.
//

import Foundation

typealias Scope = Dictionary<String, Bool>

enum FunctionType {
    case none, function
}

class Resolver {
    let interpreter: Interpreter
    let errorReporting: ErrorReporting
    var currentFunction = FunctionType.none
    var scopes = [Scope]()
    
    init(interpreter: Interpreter, errorReporting: ErrorReporting) {
        self.interpreter = interpreter
        self.errorReporting = errorReporting
    }
    
    func resolve(_ statements: [Stmt]) {
        do {
            for statement in statements {
                try resolve(statement)
            }
        } catch {
            
        }
    }
    
    func resolve(_ statement: Stmt) throws {
        try statement.accept(visitor: self)
    }
    
    func resolve(_ expr: Expr) throws {
        try expr.accept(visitor: self)
    }
    
    func resolveFunction(_ function: Stmt.Function, _ type: FunctionType) throws {
        let enclosingFunction = currentFunction
        currentFunction = type
        beginScope()
        for param in function.params {
            declare(param)
            define(param)
        }
        resolve(function.body)
        endScope()
        currentFunction = enclosingFunction
    }
    
    func beginScope() {
        scopes.append(Scope())
    }
    
    func endScope() {
        _ = scopes.popLast()
    }
    
    func declare(_ name: Token) {
        guard (!scopes.isEmpty) else { return }
        
        var currentScope = scopes[scopes.count - 1]
        if (currentScope.keys.contains(name.lexeme)) {
            errorReporting.error(at: name, message: "Already a variable with this name in this scope.")
        }
        currentScope[name.lexeme] = false
    }
    
    func define(_ name: Token) {
        guard (!scopes.isEmpty) else { return }
        scopes[scopes.count - 1][name.lexeme] = true
    }
    
    func resolveLocal(_ expr: Expr, _ name: Token) {
        for index in stride(from: scopes.count-1, through: 0, by: -1) {
            if (scopes[index].keys.contains(name.lexeme)) {
                interpreter.resolve(expr, scopes.count-1-index)
            }
        }
    }
}

extension Resolver: ExprVisitor {
    func visitAssignExpr(_ expr: Expr.Assign) throws -> Void {
        try resolve(expr.value)
        resolveLocal(expr, expr.name)
    }
    
    func visitBinaryExpr(_ expr: Expr.Binary) throws -> Void {
        try resolve(expr.left)
        try resolve(expr.right)
    }
    
    func visitCallExpr(_ expr: Expr.Call) throws -> Void {
        try resolve(expr.callee)
        for arg in expr.arguments {
            try resolve(arg)
        }
    }
    
    func visitGroupingExpr(_ expr: Expr.Grouping) throws -> Void {
        try resolve(expr.expression)
    }
    
    func visitLiteralExpr(_ expr: Expr.Literal) throws -> Void {
        
    }
    
    func visitLogicalExpr(_ expr: Expr.Logical) throws -> Void {
        try resolve(expr.left)
        try resolve(expr.right)
    }
    
    func visitUnaryExpr(_ expr: Expr.Unary) throws -> Void {
        try resolve(expr.right)
    }
    
    func visitVariableExpr(_ expr: Expr.Variable) throws -> Void {
        if (!scopes.isEmpty && scopes[scopes.count - 1][expr.name.lexeme] == false) {
            errorReporting.error(at: expr.name, message: "Can't read local variable in its own initializer.")
        }
        resolveLocal(expr, expr.name)
    }
    
}

extension Resolver: StmtVisitor {
    func visitExpressionStmt(_ stmt: Stmt.Expression) throws -> Void {
        try resolve(stmt.expression)
    }
    
    func visitFunctionStmt(_ stmt: Stmt.Function) throws -> Void {
        declare(stmt.name)
        define(stmt.name)
        try resolveFunction(stmt, FunctionType.function)
    }
    
    func visitIfStmt(_ stmt: Stmt.If) throws -> Void {
        try resolve(stmt.condition)
        try resolve(stmt.thenBranch)
        if let elseBranch = stmt.elseBranch {
            try resolve(elseBranch)
        }
    }
    
    func visitPrintStmt(_ stmt: Stmt.Print) throws -> Void {
        try resolve(stmt.expression)
    }
    
    func visitReturnStmt(_ stmt: Stmt.Return) throws -> Void {
        if (currentFunction == FunctionType.none) {
            errorReporting.error(at: stmt.keyword, message: "Can't return from top-level code.")
        }
        if let value = stmt.value {
            try resolve(value)
        }
    }
    
    func visitVarStmt(_ stmt: Stmt.Var) throws -> Void {
        declare(stmt.name)
        if let stmtInit = stmt.initializer {
            try resolve(stmtInit)
        }
        define(stmt.name)
    }
    
    func visitWhileStmt(_ stmt: Stmt.While) throws -> Void {
        try resolve(stmt.condition)
        try resolve(stmt.body)
    }
    
    func visitBlockStmt(_ stmt: Stmt.Block) throws -> Void {
        beginScope()
        resolve(stmt.statements)
        endScope()
    }
}
