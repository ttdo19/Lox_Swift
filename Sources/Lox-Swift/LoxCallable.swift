//
//  File.swift
//  
//
//  Created by Trang Do on 9/14/24.
//

import Foundation

protocol LoxCallable {
    var arity: Int { get }
    func call(interpreter: Interpreter, arguments: [Any?]) throws -> Any?
}
