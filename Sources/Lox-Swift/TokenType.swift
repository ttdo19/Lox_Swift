//
//  TokenType.swift
//  Lox
//
//  Created by Trang Do on 9/6/24.
//

import Foundation

enum TokenType {
    // single-character tokens.
      case leftParen, rightParen, leftBrace, rightBrace, comma, dot, minus, plus, semicolon, slash, star

      // one or two character tokens.
      case bang, bangEqual, equal, equalEqual, greater, greaterEqual, less, lessEqual

      // literals.
      case identifier, string, number

      // keywords.
      case And, Class, Else, False, Fun, For, If, Nil, Or, Print, Return, Super, This, True, Var, While

      case eof
}
