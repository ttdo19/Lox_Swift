//
//  File.swift
//  
//
//  Created by Trang Do on 9/10/24.
//

import Foundation

enum RuntimeError: Error {
    case mismatchedType(Token, String)
    case unexpected(String)
    case undefinedVariable(Token, String)
    case notCallable(Token, String)
    case incorrectNumberArguments(Token, String)
}

enum Return: Error {
    case functionReturn(Any?)
}
