//
//  Expressions.swift
//  Symbols
//
//  Created by Palle Klewitz on 30.05.17.
//	Copyright (c) 2017 Palle Klewitz
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

/// A mathematical expression
///
/// - number: A (constant) number literal
/// - variable: A variable which can be replaced by another expression or number
/// - constant: A named constant value.
/// - add: An addition of expressions
/// - multiply: A multiplication of expressions
/// - negate: A negation of expressions. (-1 * expression)
/// - invert: An inverted expression. (1 / expression)
/// - exp: An exponentiated expression
/// - log: The (natural) logarithm of an expression
/// - sin: The sine of an expression
/// - cos: The cosine of an expression
/// - tan: The tangens of an expression
/// - asin: The arcus sinus (inverse sine) of an expression
/// - acos: The arcus cosinus (inverse cosine) of an expression
/// - atan: The arcus tangens (inverse tangens) of an expression
/// - sinh: The hyperbolic sine of an expression
/// - cosh: The hyperbolic cosine of an expression
/// - tanh: The hyperbolic tangens of an expression
public indirect enum Expression {
	
	/// A constant number literal
	case number(Number)
	
	/// A variable, which can be replaced by another expression or number
	/// at the time of evaluation
	case variable(String)
	
	/// A named constant
	/// Acts the same as a number on evaluation but is printed
	/// as another string. (e.g. π)
	case constant(String, Number)
	
	/// An addition of expressions
	case add([Expression])
	
	/// A multiplication of expressions
	case multiply([Expression])
	
	/// A negation of an expression.
	case negate(Expression)
	
	/// The inverse of an expression.
	/// (expression^-1)
	case invert(Expression)
	
	/// The exponential function of an expression
	case exp(base: Expression, exponent: Expression)
	
	/// The natural logarithm of an expression
	case log(Expression)
	
	/// The sine function
	case sin(Expression)
	
	/// The cosine function
	case cos(Expression)
	
	/// The tangens function
	case tan(Expression)
	
	/// The inverse sine function
	case asin(Expression)
	
	case acos(Expression)
	case atan(Expression)
	
	case sinh(Expression)
	case cosh(Expression)
	case tanh(Expression)
	
	case abs(Expression)
	
	case function(parameters: [Expression], name: String)
	case branch([(Predicate, Expression)])
	
	case sum(parameter: String, start: Expression, end: Expression, summand: Expression)
}

public extension Expression {
	public static var i: Expression {
		return .constant("i", Number.i)
	}
	
	public static var pi: Expression {
		return .constant("π", Number.pi)
	}
	
	public static var e: Expression {
		return .constant("e", Number.e)
	}
}

extension Expression: ExpressibleByFloatLiteral {
	public typealias FloatLiteralType = Double
	
	public init(floatLiteral value: Double) {
		self = .number(Number(floatLiteral: value))
	}
}

extension Expression: ExpressibleByIntegerLiteral {
	public typealias IntegerLiteralType = Int
	
	public init(integerLiteral value: Int) {
		self = .number(Number(integerLiteral: value))
	}
}

extension Expression: ExpressibleByStringLiteral {
	public typealias StringLiteralType					= String
	public typealias UnicodeScalarLiteralType			= UnicodeScalar
	public typealias ExtendedGraphemeClusterLiteralType = ExtendedGraphemeClusterType
	
	public init(stringLiteral value: StringLiteralType) {
		self = .variable(value)
	}
	
	public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
		self = .variable(String(value))
	}

	public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
		self = .variable(value)
	}
}

public extension Expression {
	public init(_ scalar: Scalar) {
		self = .number(Number.real(scalar))
	}
	
	public init(_ number: Number) {
		self = .number(number)
	}
}

public extension Expression {
	public func contains(variable: String) -> Bool {
		switch self {
		case .number(_):
			return false
			
		case .variable(let name):
			return name == variable
			
		case .constant(_, _):
			return false
			
		case .add(let expressions):
			return expressions.contains(where: { expression -> Bool in
				expression.contains(variable: variable)
			})
			
		case .multiply(let expressions):
			return expressions.contains(where: { expression -> Bool in
				expression.contains(variable: variable)
			})
			
		case .negate(let expression):
			return expression.contains(variable: variable)
			
		case .invert(let expression):
			return expression.contains(variable: variable)
			
		case .exp(let base, let exponent):
			return base.contains(variable: variable) || exponent.contains(variable: variable)
			
		case .log(let expression):
			return expression.contains(variable: variable)
			
		case .sin(let expression):
			return expression.contains(variable: variable)
			
		case .cos(let expression):
			return expression.contains(variable: variable)
			
		case .tan(let expression):
			return expression.contains(variable: variable)
			
		case .asin(let expression):
			return expression.contains(variable: variable)
			
		case .acos(let expression):
			return expression.contains(variable: variable)
			
		case .atan(let expression):
			return expression.contains(variable: variable)
			
		case .sinh(let expression):
			return expression.contains(variable: variable)
			
		case .cosh(let expression):
			return expression.contains(variable: variable)
			
		case .tanh(let expression):
			return expression.contains(variable: variable)
			
		case .function(let parameters, _):
			return parameters.contains(where: { expression -> Bool in
				return expression.contains(variable: variable)
			})
			
		case .branch(let options):
			return options.contains(where: { option -> Bool in
				return option.0.contains(variable: variable) || option.1.contains(variable: variable)
			})
			
		case .abs(let expression):
			return expression.contains(variable: variable)
			
		case .sum(let parameter, _, _, _) where parameter == variable:
			return false
			
		case .sum(parameter: _, start: let start, end: let end, summand: let summand):
			return start.contains(variable: variable)
				|| end.contains(variable: variable)
				|| summand.contains(variable: variable)
		}
	}
}

