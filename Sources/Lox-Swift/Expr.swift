import Foundation

protocol ExprVisitor {
    associatedtype ExprVisitorReturnType
    func visitBinaryExpr (_ expr: Expr.Binary) throws -> ExprVisitorReturnType
    func visitGroupingExpr (_ expr: Expr.Grouping) throws -> ExprVisitorReturnType
    func visitLiteralExpr (_ expr: Expr.Literal) throws -> ExprVisitorReturnType
    func visitUnaryExpr (_ expr: Expr.Unary) throws -> ExprVisitorReturnType
}
class Expr {
    func accept<V: ExprVisitor, R>(visitor: V) throws -> R where R == V.ExprVisitorReturnType {
        fatalError()
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
}
