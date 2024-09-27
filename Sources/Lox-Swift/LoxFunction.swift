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
    let isInitializer: Bool
    var arity: Int {
        declaration.params.count
    }
    var description: String {
        "<fn \(declaration.name.lexeme)>"
    }
    
    init(declaration: Stmt.Function, closure: Environment, isInitialize: Bool) {
        self.declaration = declaration
        self.closure = closure
        self.isInitializer = isInitialize
    }

    func bind(_ instance: LoxInstance) -> LoxFunction {
        let environment = Environment(enclosing: closure)
        environment.define(name: "this", value: instance)
        return LoxFunction(declaration: declaration, closure: environment, isInitialize: isInitializer)
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
            if (isInitializer) {return try closure.getAt(0, "this")}
            return value
        }
        if (isInitializer) { return try closure.getAt(0, "this") }
        return nil
    }
}

extension LoxFunction: Equatable {
    static func == (lhs: LoxFunction, rhs: LoxFunction) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}
