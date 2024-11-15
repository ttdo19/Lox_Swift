import Foundation

protocol StmtVisitor {
    associatedtype StmtVisitorReturnType
    func visitBlockStmt (_ stmt: Stmt.Block) throws -> StmtVisitorReturnType
    func visitClassStmt (_ stmt: Stmt.Class) throws -> StmtVisitorReturnType
    func visitExpressionStmt (_ stmt: Stmt.Expression) throws -> StmtVisitorReturnType
    func visitFunctionStmt (_ stmt: Stmt.Function) throws -> StmtVisitorReturnType
    func visitIfStmt (_ stmt: Stmt.If) throws -> StmtVisitorReturnType
    func visitPrintStmt (_ stmt: Stmt.Print) throws -> StmtVisitorReturnType
    func visitReturnStmt (_ stmt: Stmt.Return) throws -> StmtVisitorReturnType
    func visitVarStmt (_ stmt: Stmt.Var) throws -> StmtVisitorReturnType
    func visitWhileStmt (_ stmt: Stmt.While) throws -> StmtVisitorReturnType
}
class Stmt {
    func accept<V: StmtVisitor, R>(visitor: V) throws -> R where R == V.StmtVisitorReturnType {
        fatalError()
    }
    class Block: Stmt {
        let statements: [Stmt]

        init(statements: [Stmt]) {
            self.statements = statements
        }

        override func accept<V: StmtVisitor, R>(visitor: V) throws -> R where R == V.StmtVisitorReturnType {
            return try visitor.visitBlockStmt(self)
        }
    }
    class Class: Stmt {
        let name: Token
        let superclass: Expr.Variable?
        let methods: [Stmt.Function]

        init(name: Token, superclass: Expr.Variable?, methods: [Stmt.Function]) {
            self.name = name
            self.superclass = superclass
            self.methods = methods
        }

        override func accept<V: StmtVisitor, R>(visitor: V) throws -> R where R == V.StmtVisitorReturnType {
            return try visitor.visitClassStmt(self)
        }
    }
    class Expression: Stmt {
        let expression: Expr

        init(expression: Expr) {
            self.expression = expression
        }

        override func accept<V: StmtVisitor, R>(visitor: V) throws -> R where R == V.StmtVisitorReturnType {
            return try visitor.visitExpressionStmt(self)
        }
    }
    class Function: Stmt {
        let name: Token
        let params: [Token]
        let body: [Stmt]

        init(name: Token, params: [Token], body: [Stmt]) {
            self.name = name
            self.params = params
            self.body = body
        }

        override func accept<V: StmtVisitor, R>(visitor: V) throws -> R where R == V.StmtVisitorReturnType {
            return try visitor.visitFunctionStmt(self)
        }
    }
    class If: Stmt {
        let condition: Expr
        let thenBranch: Stmt
        let elseBranch: Stmt?

        init(condition: Expr, thenBranch: Stmt, elseBranch: Stmt?) {
            self.condition = condition
            self.thenBranch = thenBranch
            self.elseBranch = elseBranch
        }

        override func accept<V: StmtVisitor, R>(visitor: V) throws -> R where R == V.StmtVisitorReturnType {
            return try visitor.visitIfStmt(self)
        }
    }
    class Print: Stmt {
        let expression: Expr

        init(expression: Expr) {
            self.expression = expression
        }

        override func accept<V: StmtVisitor, R>(visitor: V) throws -> R where R == V.StmtVisitorReturnType {
            return try visitor.visitPrintStmt(self)
        }
    }
    class Return: Stmt {
        let keyword: Token
        let value: Expr?

        init(keyword: Token, value: Expr?) {
            self.keyword = keyword
            self.value = value
        }

        override func accept<V: StmtVisitor, R>(visitor: V) throws -> R where R == V.StmtVisitorReturnType {
            return try visitor.visitReturnStmt(self)
        }
    }
    class Var: Stmt {
        let name: Token
        let initializer: Expr?

        init(name: Token, initializer: Expr?) {
            self.name = name
            self.initializer = initializer
        }

        override func accept<V: StmtVisitor, R>(visitor: V) throws -> R where R == V.StmtVisitorReturnType {
            return try visitor.visitVarStmt(self)
        }
    }
    class While: Stmt {
        let condition: Expr
        let body: Stmt

        init(condition: Expr, body: Stmt) {
            self.condition = condition
            self.body = body
        }

        override func accept<V: StmtVisitor, R>(visitor: V) throws -> R where R == V.StmtVisitorReturnType {
            return try visitor.visitWhileStmt(self)
        }
    }
}
