//
//  File.swift
//  
//
//  Created by Trang Do on 9/14/24.
//

import Foundation

class LoxFunction: LoxCallable {
    let declaration: Stmt.Function
    let closure: Environment
    var arity: Int {
        declaration.params.count
    }
    var description: String {
        "<fn \(declaration.name.lexeme)>"
    }
    
    init(declaration: Stmt.Function, closure: Environment) {
        self.declaration = declaration
        self.closure = closure
    }

    
    func call(interpreter: Interpreter, arguments: [Any?]) throws -> Any? {
        let environment = Environment(enclosing: closure)
        let range = 0..<declaration.params.count
        for i in range {
            environment.define(name: declaration.params[i].lexeme, value: arguments[i])
        }
        do {
            try interpreter.executeBlock(statements: declaration.body, environment: environment)
        } catch Return.functionReturn(let value) {
            return value
        }
        return nil
    }
}
