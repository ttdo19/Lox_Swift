import Foundation

protocol ExprVisitor {
    associatedtype ExprVisitorReturnType
    func visitAssignExpr (_ expr: Expr.Assign) throws -> ExprVisitorReturnType
    func visitBinaryExpr (_ expr: Expr.Binary) throws -> ExprVisitorReturnType
    func visitCallExpr (_ expr: Expr.Call) throws -> ExprVisitorReturnType
    func visitGroupingExpr (_ expr: Expr.Grouping) throws -> ExprVisitorReturnType
    func visitLiteralExpr (_ expr: Expr.Literal) throws -> ExprVisitorReturnType
    func visitLogicalExpr (_ expr: Expr.Logical) throws -> ExprVisitorReturnType
    func visitUnaryExpr (_ expr: Expr.Unary) throws -> ExprVisitorReturnType
    func visitVariableExpr (_ expr: Expr.Variable) throws -> ExprVisitorReturnType
}
class Expr {
    func accept<V: ExprVisitor, R>(visitor: V) throws -> R where R == V.ExprVisitorReturnType {
        fatalError()
    }
    class Assign: Expr {
        let name: Token
        let value: Expr

        init(name: Token, value: Expr) {
            self.name = name
            self.value = value
        }

        override func accept<V: ExprVisitor, R>(visitor: V) throws -> R where R == V.ExprVisitorReturnType {
            return try visitor.visitAssignExpr(self)
        }
    }
    class Binary: Expr {
        let left: Expr
        let op: Token
        let right: Expr

        init(left: Expr, op: Token, right: Expr) {
            self.left = left
            self.op = op
            self.right = right
        }

        override func accept<V: ExprVisitor, R>(visitor: V) throws -> R where R == V.ExprVisitorReturnType {
            return try visitor.visitBinaryExpr(self)
        }
    }
    class Call: Expr {
        let callee: Expr
        let paren: Token
        let arguments: [Expr]

        init(callee: Expr, paren: Token, arguments: [Expr]) {
            self.callee = callee
            self.paren = paren
            self.arguments = arguments
        }

        override func accept<V: ExprVisitor, R>(visitor: V) throws -> R where R == V.ExprVisitorReturnType {
            return try visitor.visitCallExpr(self)
        }
    }
    class Grouping: Expr {
        let expression: Expr

        init(expression: Expr) {
            self.expression = expression
        }

        override func accept<V: ExprVisitor, R>(visitor: V) throws -> R where R == V.ExprVisitorReturnType {
            return try visitor.visitGroupingExpr(self)
        }
    }
    class Literal: Expr {
        let value: Any?

        init(value: Any?) {
            self.value = value
        }

        override func accept<V: ExprVisitor, R>(visitor: V) throws -> R where R == V.ExprVisitorReturnType {
            return try visitor.visitLiteralExpr(self)
        }
    }
    class Logical: Expr {
        let left: Expr
        let op: Token
        let right: Expr

        init(left: Expr, op: Token, right: Expr) {
            self.left = left
            self.op = op
            self.right = right
        }

        override func accept<V: ExprVisitor, R>(visitor: V) throws -> R where R == V.ExprVisitorReturnType {
            return try visitor.visitLogicalExpr(self)
        }
    }
    class Unary: Expr {
        let op: Token
        let right: Expr

        init(op: Token, right: Expr) {
            self.op = op
            self.right = right
        }

        override func accept<V: ExprVisitor, R>(visitor: V) throws -> R where R == V.ExprVisitorReturnType {
            return try visitor.visitUnaryExpr(self)
        }
    }
    class Variable: Expr {
        let name: Token

        init(name: Token) {
            self.name = name
        }

        override func accept<V: ExprVisitor, R>(visitor: V) throws -> R where R == V.ExprVisitorReturnType {
            return try visitor.visitVariableExpr(self)
        }
    }
}

extension Expr: Hashable {
    static func == (lhs: Expr, rhs: Expr) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func hash(into hasher: inout Hasher) {
        return ObjectIdentifier(self).hash(into: &hasher)
    }
}
