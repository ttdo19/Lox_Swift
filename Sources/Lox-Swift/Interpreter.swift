//
//  File.swift
//  
//
//  Created by Trang Do on 9/10/24.
//

import Foundation

class Interpreter {
    var errorReporting: ErrorReporting!
    
    func interpret(_ expr: Expr) {
        do {
            let value = try evaluate(expr)
            print(stringify(value))
        } catch let error as RuntimeError {
            errorReporting.runtimeError(error)
        } catch {
            let unexpectedError = RuntimeError.unexpected("Unexpected runtime error: \(error.localizedDescription)")
            errorReporting.runtimeError(unexpectedError)
        } 
    }
}

extension Interpreter: ExprVisitor {
    func visitGroupingExpr(_ expr: Expr.Grouping) throws -> Any? {
        return try evaluate(expr.expression)
    }
    
    func evaluate(_ expr: Expr) throws -> Any? {
        return try expr.accept(visitor: self)
    }
    
    func visitLiteralExpr(_ expr: Expr.Literal) throws -> Any? {
        return expr.value
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
    
    func stringify(_ object: Any?) -> String {
        guard object != nil else {return "nil"}
        
        if let obj = object as? Double {
            var text = String(obj)
            text = text.hasSuffix(".0") ? String(text.dropLast(2)): text
            return text
        }
        return String(describing: object)
    }
}
