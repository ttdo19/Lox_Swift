//
//  ErrorReporting.swift
//  Lox
//
//  Created by Trang Do on 9/5/24.
//

import Foundation

protocol ErrorReporting {
    var hadError: Bool {get}
    var hadRuntimeError: Bool {get}
    func error(_ line: Int, _ message: String)
    func report(_ line: Int, _ at: String, _ message: String)
    func error(at token: Token, message: String)
    func runtimeError(_ error: RuntimeError)
}
