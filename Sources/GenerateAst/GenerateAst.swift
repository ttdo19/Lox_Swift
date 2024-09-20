//
//  GenerateAst.swift
//  GenerateAst
//
//  Created by Trang Do on 9/8/24.
//

import Foundation

typealias Field = (name: String, type: String)

class GenerateAst {
    func generateAst() {
        defineAst(outputDir: CommandLine.arguments[1], baseName: "Expr", types: [
            "Assign     : Token name, Expr value",
            "Binary     : Expr left, Token op, Expr right",
            "Call       : Expr callee, Token paren, [Expr] arguments",
            "Get        : Expr object, Token name",
            "Grouping   : Expr expression",
            "Literal    : Any? value",
            "Logical    : Expr left, Token op, Expr right",
            "Set        : Expr object, Token name, Expr value",
            "Super      : Token keyword, Token method",
            "This       : Token keyword",
            "Unary      : Token op, Expr right",
            "Variable   : Token name"
        ])
        defineAst(outputDir: CommandLine.arguments[1], baseName: "Stmt", types: [
            "Block      : [Stmt] statements",
            "Class      : Token name, Expr.Variable? superclass, [Stmt.Function] methods",
            "Expression : Expr expression",
            "Function   : Token name, [Token] params, [Stmt] body",
            "If         : Expr condition, Stmt thenBranch, Stmt? elseBranch",
            "Print      : Expr expression",
            "Return     : Token keyword, Expr? value",
            "Var        : Token name, Expr? initializer",
            "While      : Expr condition, Stmt body"
        ])
    }
    
    func defineAst(outputDir: String, baseName: String, types: [String]) {
        let path = URL(fileURLWithPath: outputDir).appendingPathComponent("\(baseName).swift")
        let writer = PrintWriter(url: path, encoding: String.Encoding.utf8)
        writer.println("import Foundation")
        writer.println()
        defineVisitor(writer: writer, baseName: baseName, types: types)
        
        writer.println("class \(baseName) {")
        
        writer.println("    \(visitorFunc(for: baseName)) {")
        writer.println("        fatalError()")
        writer.println("    }")
        
        for typeAst in types {
            let className = typeAst.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
            let fields = typeAst.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces)
            defineType(writer: writer, baseName: baseName, className: className, fieldString: fields)
        }
        
        writer.println("}")
    }
    
    func defineType(writer: PrintWriter, baseName: String, className: String, fieldString: String) {
        writer.println("    class \(className): \(baseName) {")
        let fieldsList = seperateFields(fieldString)
        let arguments = makeArguments(from: fieldsList)
        
        // Fields
        for field in fieldsList {
            writer.println("        let \(field.name): \(field.type)")
        }
        writer.println()
        // Constructor
        writer.println("        init(\(arguments)) {")
        
        //Store parameters in fields
        for field in fieldsList {
            writer.println("            self.\(field.name) = \(field.name)")
        }
        writer.println("        }")
        
        // Visitor pattern
        writer.println()
        writer.println("        override \(visitorFunc(for: baseName)) {")
        writer.println("            return try visitor.visit\(className)\(baseName)(self)")
        writer.println("        }")
        writer.println("    }")
    }
    
    func defineVisitor(writer: PrintWriter, baseName: String, types: [String]) {
        writer.println("protocol \(baseName)Visitor {")
        writer.println("    associatedtype \(baseName)VisitorReturnType")
        for typeVisitor in types {
            let typeName = typeVisitor.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
            writer.println("    func visit\(typeName)\(baseName) (_ \(baseName.lowercased()): \(baseName).\(typeName)) throws -> \(baseName)VisitorReturnType")
        }
        writer.println("}")
    }
    
    func seperateFields(_ fieldsString: String) -> [Field] {
        let fields = fieldsString.components(separatedBy: ", ")
        var seperatedField: [Field] = []
        for field in fields {
            let name = field.components(separatedBy: " ")[1].trimmingCharacters(in: .whitespaces)
            let type = field.components(separatedBy: " ")[0].trimmingCharacters(in: .whitespaces)
            seperatedField.append((name, type))
        }
        return seperatedField
    }
    
    func makeArguments(from fieldsList: [Field]) -> String {
        return fieldsList.map() {"\($0.name): \($0.type)"}.joined(separator: ", ")
    }
    
    func visitorFunc(for baseName: String) -> String {
        return "func accept<V: \(baseName)Visitor, R>(visitor: V) throws -> R where R == V.\(baseName)VisitorReturnType"
    }
}
