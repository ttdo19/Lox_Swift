//
//  File.swift
//  
//
//  Created by Trang Do on 9/12/24.
//

import Foundation

class Environment {
    
    let enclosing: Environment?
    var values = Dictionary<String, Any?>()
    
    init(enclosing: Environment? = nil) {
        self.enclosing = enclosing
    }
    
    func get(name: Token) throws -> Any? {
        if values.contains(where: {$0.key == name.lexeme}) {
            return values[name.lexeme]!
        } else if let enclosing = enclosing {
            return try enclosing.get(name: name)
        } else {
            throw RuntimeError.undefinedVariable(name, "Undefined variable '\(name.lexeme)'.")
        }
    }
    
    func assign(_ name: Token,_ value: Any?) throws {
        if values.contains(where: {$0.key == name.lexeme}){
            values[name.lexeme] = value
        } else if let enclosing = enclosing {
            try enclosing.assign(name, value)
        } else {
            throw RuntimeError.undefinedVariable(name, "Undefined variable '\(name.lexeme)'.")
        }
    }
    
    func define(name: String, value: Any?) {
        values[name] = value
    }
}
