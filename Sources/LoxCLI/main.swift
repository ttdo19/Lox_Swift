//
//  main.swift
//  Lox
//
//  Created by Trang Do on 9/5/24.
//

import Foundation
import Lox_Swift

guard CommandLine.arguments.count < 3 else {
    print("Usage: jlox [script]")
    exit(EX_USAGE)
}

private let lox = Lox()

if CommandLine.arguments.count == 2 {
    lox.runFile(CommandLine.arguments[1])
} else {
    lox.runPrompt()
}





