//
//  File.swift
//  
//
//  Created by Trang Do on 9/10/24.
//

import Foundation

class Interpreter {
    var errorReporting: ErrorReporting!
    var environment = Environment()
    func interpret(_ statements: [Stmt]) {
        do {
            for statement in statements {
                try execute(statement)
            }
        } catch let error as RuntimeError {
            errorReporting.runtimeError(error)
        } catch {
            let unexpectedError = RuntimeError.unexpected("Unexpected runtime error: \(error.localizedDescription)")
            errorReporting.runtimeError(unexpectedError)
        } 
    }
    
    func evaluate(_ expr: Expr) throws -> Any? {
        return try expr.accept(visitor: self)
    }
    
    func stringify(_ object: Any?) -> String {
        guard object != nil else {return "nil"}
        
        if let obj = object as? Double {
            var text = String(obj)
            text = text.hasSuffix(".0") ? String(text.dropLast(2)): text
            return text
        }
        return String(describing: object)
    }
    
    func execute(_ stmt: Stmt) throws {
        try stmt.accept(visitor: self)
    }
    
    func executeBlock(statements: [Stmt], environment: Environment) throws {
        let previous = self.environment
        
        self.environment = environment
        defer {
            self.environment = previous
        }
        
        for statement in statements {
            try execute(statement)
        }
    }
}

extension Interpreter: ExprVisitor {
    func visitGroupingExpr(_ expr: Expr.Grouping) throws -> Any? {
        return try evaluate(expr.expression)
    }
    
    func visitLiteralExpr(_ expr: Expr.Literal) throws -> Any? {
        return expr.value
    }
    
    func visitLogicalExpr(_ expr: Expr.Logical) throws -> Any? {
        let left = try evaluate(expr.left)
        
        if (expr.op.type == TokenType.Or) {
            if (isTruthy(left)) { return left }
        } else {
            if (!isTruthy(left)) {return left}
        }
        return try evaluate(expr.right)
    }
    
    func visitUnaryExpr(_ expr: Expr.Unary) throws -> Any? {
        let right = try evaluate(expr.right)
        
        switch expr.op.type {
        case .minus:
            let operand = try checkNumberOperand(op: expr.op, operand: right)
            return -operand
        case .bang:
            return !isTruthy(right)
        default:
            break
        }
        return nil
    }
    
    func visitVariableExpr(_ expr: Expr.Variable) throws -> Any? {
        return try environment.get(name: expr.name)
    }
    
    func visitAssignExpr(_ expr: Expr.Assign) throws -> Any? {
        let value = try evaluate(expr.value)
        try environment.assign(expr.name, value)
        return value
    }
    
    func isTruthy(_ object: Any?) -> Bool {
        guard (object != nil) else {return false}
        if let object = object as? Bool { return object }
        return true
    }
    
    func visitBinaryExpr(_ expr: Expr.Binary) throws -> Any?{
        let left = try evaluate(expr.left)
        let right = try evaluate(expr.right)
        
        switch expr.op.type {
        case .bangEqual:
            return !isEqual(left, right)
        case .equalEqual:
            return isEqual(left, right)
        case .greater:
            let (l, r) = try checkNumberOperands(op: expr.op, left, right)
            return l > r
        case .greaterEqual:
            let (l, r) = try checkNumberOperands(op: expr.op, left, right)
            return l >= r
        case .less:
            let (l, r) = try checkNumberOperands(op: expr.op, left, right)
            return l < r
        case .lessEqual:
            let (l, r) = try checkNumberOperands(op: expr.op, left, right)
            return l <= r
        case .minus:
            let (l, r) = try checkNumberOperands(op: expr.op, left, right)
            return l-r
        case .plus:
            if let left = left as? Double, let right = right as? Double {
                return left + right
            }
            if let left = left as? String, let right = right as? String {
                return left + right
            }
            throw RuntimeError.mismatchedType(expr.op, "Operands must be two numbers or two strings.")
        case .slash:
            let (l, r) = try checkNumberOperands(op: expr.op, left, right)
            return l/r
        case .star:
            let (l, r) = try checkNumberOperands(op: expr.op, left, right)
            return l*r
        default:
            break
        }
        return nil
    }
    
    func isEqual(_ a: Any?, _ b: Any?) -> Bool {
        if (a == nil && b == nil) { return true }
        else if (a == nil) {return false}
        else if let a = a as? Bool, let b = b as? Bool { return a == b}
        else if let a = a as? Double, let b = b as? Double { return a == b}
        else if let a = a as? String, let b = b as? String { return a == b}
        
        return false
    }
    
    func checkNumberOperand(op: Token, operand: Any?) throws -> Double{
        if let op = operand as? Double {return op}
        throw RuntimeError.mismatchedType(op, "Operand must be a number.")
    }
    
    func checkNumberOperands(op: Token, _ left: Any?, _ right: Any?) throws -> (Double, Double) {
        if let left = left as? Double, let right = right as? Double {return (left, right)}
        throw RuntimeError.mismatchedType(op, "Operand must be numbers.")
    }
    
    
}

extension Interpreter: StmtVisitor {
    
    func visitExpressionStmt(_ stmt: Stmt.Expression) throws -> Void {
        let _ = try evaluate(stmt.expression)
    }
    
    func visitIfStmt(_ stmt: Stmt.If) throws -> Void {
        if (isTruthy(try evaluate(stmt.condition))) {
            try execute(stmt.thenBranch)
        } else if let elseBranch = stmt.elseBranch {
            try execute(elseBranch)
        }
    }
    
    func visitPrintStmt(_ stmt: Stmt.Print) throws -> Void {
        let value = try evaluate(stmt.expression)
        print(stringify(value))
    }
    
    func visitVarStmt(_ stmt: Stmt.Var) throws -> Void {
        var value : Any? = nil
        if let val = stmt.initializer {
            value = try evaluate(val)
        }
        environment.define(name: stmt.name.lexeme, value: value)
    }
    
    func visitWhileStmt(_ stmt: Stmt.While) throws -> Void {
        while (isTruthy(try evaluate(stmt.condition))) {
            try execute(stmt.body)
        }
    }
    
    func visitBlockStmt(_ stmt: Stmt.Block) throws -> () {
        try executeBlock(statements: stmt.statements, environment: Environment(enclosing: environment))
    }
    
}
