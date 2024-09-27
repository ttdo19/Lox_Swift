//
//  File.swift
//  
//
//  Created by Trang Do on 9/19/24.
//

import Foundation

typealias Field = Dictionary<String, Any?>

class LoxInstance {
    let klass: LoxClass
    var fields = Field()
    
    init(klass: LoxClass) {
        self.klass = klass
    }
    
    func get(_ name: Token) throws -> Any? {
        if (fields.keys.contains(name.lexeme)) {
            return fields[name.lexeme] as Any?
        }
        
        if let method = klass.findMethod(name.lexeme) {
            return method.bind(self)
        }
        
        throw RuntimeError.cannotGetProperty(name, "Undefined property \(name.lexeme).")
    }
    
    func toString() -> String {
        return klass.name + " instance"
    }
    
    func set(_ name: Token, _ value: Any?) {
        fields[name.lexeme] = value
    }
    
}

extension LoxInstance: Equatable {
    static func == (lhs: LoxInstance, rhs: LoxInstance) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}
