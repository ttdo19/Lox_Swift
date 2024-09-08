//
//  GenerateAst.swift
//  GenerateAst
//
//  Created by Trang Do on 9/8/24.
//

import Foundation

class GenerateAst {
    func defineAst(outputDir: String, baseName: String, types: [String]) {
        let path = URL(fileURLWithPath: outputDir).appendingPathComponent("\(baseName).swift")
        let writer = PrintWriter(url: path, encoding: String.Encoding.utf8)
        
        writer.println("package com.craftinginterpreters.lox;")
        writer.println()
        writer.println("import java.util.List;")
        writer.println()
        writer.println("abstract class " + baseName + " {")

        for typeAst in types {
            let className = typeAst.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
            let fields = typeAst.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces)
//            defineType(writer, baseName, className, fields)
        }
        writer.println("}")
    }
    
    func defineAst(writer: PrintWriter, baseName: String, className: String, fieldList: String) {
        writer.println("    class \(className) extends \(baseName) {")
        
        // Constructor
        writer.println("    \(className) ( \(fieldList) {")
        
        //Store parameters in fields
        let fields = fieldList.components(separatedBy: ", ")
        for field in fields {
            let name = field.components(separatedBy: " ")[1].trimmingCharacters(in: .whitespaces)
            writer.println("    this.\(name) = \(name)")
        }
        writer.println("    }")
        
        //Fields
        writer.println()
        for field in fields {
            writer.println("    final \(field)")
        }
        
        writer.println("    }")
    }
}
