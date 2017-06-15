//
//  StringConversion.swift
//  Symbols
//
//  Created by Palle Klewitz on 30.05.17.
//  Copyright (c) 2017 Palle Klewitz
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

import Foundation

enum ExpressionPrecedence: Int {
	case branch = 0
	case addition
	case multiplication
	case exponentiation
	case atom
}

extension ExpressionPrecedence: Comparable {
	static func <(lhs: ExpressionPrecedence, rhs: ExpressionPrecedence) -> Bool {
		return lhs.rawValue < rhs.rawValue
	}
}

extension Expression {
	var precedence: ExpressionPrecedence {
		switch self {
		case .number(Number.complex(_, _)):
			return .addition
			
		case .number(Number.imaginary(_)):
			return .multiplication
			
		case .number(_):
			return .atom
			
		case .invert(_):
			return .multiplication
			
		case .negate(_):
			return .atom
			
		case .multiply(_):
			return .multiplication
			
		case .add(_):
			return .addition
			
		case .variable(_),
		     .constant(_, _):
			return .atom
			
		case .exp(_, _):
			return .exponentiation
			
		case .log(_),
		     .sin(_),
		     .cos(_),
		     .tan(_),
		     .asin(_),
		     .acos(_),
		     .atan(_),
		     .sinh(_),
			 .cosh(_),
			 .tanh(_),
			 .function(_, _):
			return .atom
			
		case .branch(_):
			return .branch
			
		case .abs(_):
			return .atom
		}
	}
}

extension Expression: CustomStringConvertible {
	public var description: String {
		switch self {
		case .number(let number):
			return number.description
			
		case .variable(let variable):
			return variable
			
		case .constant(let name, _):
			return name
			
		case .add(let expressions):
			return expressions.map { expr -> String in
				expr.precedence < .addition ? "(\(expr.description))" : expr.description
			}.joined(separator: " + ")
			
		case .multiply(let expressions):
			return expressions.map { expr -> String in
				expr.precedence < .multiplication ? "(\(expr.description))" : expr.description
				}.joined(separator: " * ")
			
		case .negate(let expression):
			return expression.precedence < .atom ? "-(\(expression.description))" : "-\(expression.description)"
			
		case .invert(let expression):
			return expression.precedence <= .multiplication ? "1 / (\(expression.description))" : "1 / \(expression.description)"
			
		case .exp(let base, let exponent):
			return "\(base.precedence <= .exponentiation ? "(\(base.description))" : "\(base.description)") ** \(exponent.precedence <= .exponentiation ? "(\(exponent.description))" : "\(exponent.description)")"
			
		case .log(let expr):
			return "log(\(expr.description))"
			
		case .sin(let expr):
			return "sin(\(expr.description))"
			
		case .cos(let expr):
			return "cos(\(expr.description))"
			
		case .tan(let expr):
			return "tan(\(expr.description))"
			
		case .asin(let expr):
			return "asin(\(expr.description))"
			
		case .acos(let expr):
			return "acos(\(expr.description))"
			
		case .atan(let expr):
			return "atan(\(expr.description))"
			
		case .sinh(let expr):
			return "sinh(\(expr.description))"
			
		case .cosh(let expr):
			return "cosh(\(expr.description))"
			
		case .tanh(let expr):
			return "tanh(\(expr.description))"
			
		case .function(let parameters, let function):
			return "\(function)(\(parameters.map {$0.description}.joined(separator: ",")))"
			
		case .branch(let options):
			return options.map({ (option) -> String in
				"if (\(option.0.description)) then (\(option.1.description))"
			}).joined(separator: " else ")
			
		case .abs(let expr):
			return "|\(expr.description)|"
		}
	}
}

extension Expression: Equatable {
	public static func == (lhs: Expression, rhs: Expression) -> Bool {
		switch (lhs, rhs) {
		case (.number(let l), .number(let r)):
			return l == r
			
		case (.variable(let l), .variable(let r)):
			return l == r
			
		case (.add(let ls), .add(let rs)):
			return ls == rs
			
		case (.multiply(let lf), .multiply(let rf)):
			return lf == rf
			
		case (.negate(let le), .negate(let re)),
		     (.invert(let le), .invert(let re)),
		     (.log(let le), .log(let re)),
		     (.sin(let le), .sin(let re)),
		     (.cos(let le), .cos(let re)),
		     (.tan(let le), .tan(let re)),
		     (.asin(let le), .asin(let re)),
		     (.acos(let le), .acos(let re)),
		     (.atan(let le), .atan(let re)),
		     (.sinh(let le), .sinh(let re)),
		     (.cosh(let le), .cosh(let re)),
		     (.tanh(let le), .tanh(let re)):
			return le == re
			
		case (.exp(let lb, let le), .exp(let rb, let re)):
			return lb == rb && le == re
			
		default:
			return false
			
		}
	}
}
