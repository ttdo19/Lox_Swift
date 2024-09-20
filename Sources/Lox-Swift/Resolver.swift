//
//  File.swift
//  
//
//  Created by Trang Do on 9/17/24.
//

import Foundation

typealias Scope = Dictionary<String, Bool>

enum FunctionType {
    case none, function, method, initializer
}

enum ClassType {
    case none, klass, subclass
}

class Resolver {
    let interpreter: Interpreter
    let errorReporting: ErrorReporting
    var currentFunction = FunctionType.none
    var currentClass = ClassType.none
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
    
    func visitGetExpr(_ expr: Expr.Get) throws -> Void {
        try resolve(expr.object)
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
    
    func visitSetExpr(_ expr: Expr.Set) throws -> Void {
        try resolve(expr.value)
        try resolve(expr.object)
    }
    
    func visitSuperExpr(_ expr: Expr.Super) throws -> Void {
        if (currentClass == ClassType.none) {
            errorReporting.error(at: expr.keyword, message: "Can't use 'super' outside of a class.")
        } else if (currentClass  != ClassType.subclass)  {
            errorReporting.error(at: expr.keyword, message: "Can't use 'super' in a class with no superclass.")
        }
        resolveLocal(expr, expr.keyword)
    }
    
    func visitThisExpr(_ expr: Expr.This) throws -> Void {
        if (currentClass == ClassType.none) {
            errorReporting.error(at: expr.keyword, message: "Can't use 'this' outside of a class.")
        }
        resolveLocal(expr, expr.keyword)
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
            if (currentFunction == FunctionType.initializer) {
                errorReporting.error(at: stmt.keyword, message: "Can't return a value from an initializer.")
            }
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
    
    func visitClassStmt(_ stmt: Stmt.Class) throws -> Void {
        let enclosingClass = currentClass
        currentClass = ClassType.klass
        
        declare(stmt.name)
        define(stmt.name)
        
        if let superclass = stmt.superclass {
            if stmt.name.lexeme == superclass.name.lexeme {
                errorReporting.error(at: superclass.name, message: "A class can't inherit from itself.")
            }
            currentClass = ClassType.subclass
            try resolve(superclass)
        }
        
        if (stmt.superclass != nil) {
            beginScope()
            scopes[scopes.count-1]["super"] = true
        }
        
        beginScope()
        scopes[scopes.count-1]["this"] = true
        
        for method in stmt.methods {
            var declaration = FunctionType.method
            if (method.name.lexeme == "init") {
                declaration = FunctionType.initializer
            }
            try resolveFunction(method, declaration)
        }
        
        endScope()
        
        if (stmt.superclass != nil) {
            endScope()
        }
        currentClass = enclosingClass
    }
}
