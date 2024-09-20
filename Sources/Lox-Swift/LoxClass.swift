//
//  File.swift
//  
//
//  Created by Trang Do on 9/19/24.
//

import Foundation

class LoxClass : LoxCallable {
    var arity : Int {
        if let initializer = findMethod("init") {
            return initializer.arity
        }
        return 0
    }
    
    var methods: Method
    let name: String
    let superclass: LoxClass?
    
    init(name: String, superclass: LoxClass?, methods: Method) {
        self.name = name
        self.methods = methods
        self.superclass = superclass
    }
    
    func findMethod(_ name:  String) -> LoxFunction? {
        if methods.keys.contains(name) {
            return methods[name]
        }
        
        if let superclass = superclass {
            return superclass.findMethod(name)
        }
        return nil
    }
    
    func call(interpreter: Interpreter, arguments: [Any?]) throws -> Any? {
        let instance = LoxInstance(klass: self)
        if let initializer = findMethod("init") {
            try _ = initializer.bind(instance).call(interpreter: interpreter, arguments: arguments)
        }
        return instance
    }
    

    
    func toString() -> String {
        return name
    }
    
}
