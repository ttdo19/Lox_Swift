//
//  Expr.swift
//  Lox
//
//  Created by Trang Do on 9/8/24.
//

import Foundation

class Expr {
    class Binary {
        let left: Expr
        let op: Token
        let right: Expr
        
        init(left: Expr, op: Token, right: Expr) {
            self.left = left
            self.op = op
            self.right = right
        }
    }
}
