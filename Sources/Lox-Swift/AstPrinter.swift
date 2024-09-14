//
//  File.swift
//  
//
//  Created by Trang Do on 9/8/24.
//

import Foundation

public class AstPrinter {
    func print(expr: Expr) -> String {
        do {
            return try expr.accept(visitor: self)
        } catch {
            return error.localizedDescription
        }
    }
    
    func parenthesize(name: String, exprs: Expr...) throws -> String{
        var builder = "(\(name) "
        for expr in exprs {
            try builder += expr.accept(visitor: self )
        }
        builder += ")"
        return builder
    }
    
}

extension AstPrinter: ExprVisitor {
    func visitLogicalExpr(_ expr: Expr.Logical) throws -> String {
        try parenthesize(name: expr.op.lexeme, exprs: expr.left, expr.right)
    }
    
    func visitAssignExpr(_ expr: Expr.Assign) throws -> String {
        expr.name.lexeme
    }
    
    func visitVariableExpr(_ expr: Expr.Variable) throws -> String {
        expr.name.lexeme
    }
    
    func visitGroupingExpr(_ expr: Expr.Grouping) throws -> String {
        try parenthesize(name: "group", exprs: expr.expression)
    }
    
    func visitLiteralExpr(_ expr: Expr.Literal) throws -> String {
        guard let val = expr.value else {
           return "nil"
        }
        return "\(val)"
    }
    
    func visitUnaryExpr(_ expr: Expr.Unary) throws -> String {
        try parenthesize(name: expr.op.lexeme, exprs: expr.right)
    }
    
    func visitBinaryExpr(_ expr: Expr.Binary) throws -> String{
        try parenthesize(name: expr.op.lexeme, exprs: expr.left, expr.right)
    }
    
    
}
