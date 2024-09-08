//
//  Lox.swift
//  Lox
//
//  Created by Trang Do on 9/5/24.
//

import Foundation

public class Lox: ErrorReporting{
    private(set) var hadError = false
    
    public func runFile(_ fileName: String) {
        do {
            let content = try String(contentsOfFile: fileName)
            run(content)
            if hadError {
                exit(EX_HAS_ERROR)
            }
        } catch {
            print("Unable to read this file \(fileName): \(error.localizedDescription)")
            exit(EXIT_FAILURE)
        }
    }
    
    public init(hadError: Bool = false) {
        self.hadError = hadError
    }
    
    public func runPrompt() {
        print(">")
        while true {
            guard let line = readLine() else {
                print("Unable to read input!")
                exit(EXIT_FAILURE)
            }
            if line.uppercased() == QUIT_COMMAND {
                break
            }
            run(line)
            hadError = false
        }
    }
    
    func run(_ source: String) {
        let scanner = Scanner(source: source, errorReporting: self)
        let tokens = scanner.scanTokens()
        
        for token in tokens {
            print(token.lexeme)
        }
    }
    
    func error (_ line: Int, _ message: String){
        report(line, "", message)
    }
    
    func report(_ line: Int, _ at: String, _ message: String){
        print("[line \(line)] Error \(at): \(message)")
        hadError = true
    }
}