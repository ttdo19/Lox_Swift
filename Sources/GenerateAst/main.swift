//
//  main.swift
//  GenerateAst
//
//  Created by Trang Do on 9/8/24.
//

import Foundation

guard (CommandLine.arguments.count == 2) else {
    print("Usage: generate_ast <output directory>")
    exit(EX_USAGE)
}

let generateAst = GenerateAst()
generateAst.defineAst(outputDir: CommandLine.arguments[1], baseName: "Expr", types: [
    "Binary   : Expr left, Token operator, Expr right",
    "Grouping : Expr expression",
    "Literal  : Object value",
    "Unary    : Token operator, Expr right"
])

