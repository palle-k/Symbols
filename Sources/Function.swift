//
//  Function.swift
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

public enum FunctionEvaluationError: Error {
	case invalidParameters(expected: Int, actual: Int)
}

public struct Function {
	public let name: String
	public let parameters: [String]
	public let expression: Expression
	
	public init(name: String, parameters: [String], expression: Expression) {
		self.name = name
		self.parameters = parameters
		self.expression = expression
	}
	
	public func evaluated(parameters paramValues: [Number], functions: [String: Function] = [:]) throws -> Number {
		guard paramValues.count == parameters.count else {
			throw FunctionEvaluationError.invalidParameters(expected: parameters.count, actual: paramValues.count)
		}
		
		var parameterBindings: [String: Number] = [:]
		for (paramName, paramValue) in zip(self.parameters, paramValues) {
			parameterBindings[paramName] = paramValue
		}
		
		var functionBindings = functions
		if !functionBindings.keys.contains(self.name) {
			functionBindings[self.name] = self
		}
		
		return try expression.evaluated(variables: parameterBindings, functions: functions)
	}
	
	public func derived(`for` parameter: String) -> Function {
		guard parameters.contains(parameter) else {
			return Function(name: "\(name)'", parameters: [], expression: 0)
		}
		
		func derive(expression: Expression) -> Expression {
			switch expression {
			case .variable(let variable) where variable == parameter:
				return 1
				
			case .variable(_):
				return 0
				
			case .invert(let expr):
				return -derive(expression: expr) / (expr * expr)
				
			case .negate(let expr):
				return .negate(derive(expression: expr))
				
			case .number(_):
				return 0
				
			case .add(let expressions):
				return .add(expressions.map {derive(expression: $0)})
				
			case .sin(let expr):
				return derive(expression: expr) * .cos(expr)
				
			case .cos(let expr):
				return derive(expression: expr) * .negate(.sin(expr))
				
			case .tan(let expr):
				return derive(expression: expr) / .exp(base: .cos(expr), exponent: 2)
				
			case .multiply(_):
				fatalError()
				
			case .exp(_, _):
				fatalError()
				
			default:
				fatalError()
			}
		}
		
		fatalError()
	}
}

extension Function: Equatable {
	public static func ==(lhs: Function, rhs: Function) -> Bool {
		return lhs.name == rhs.name && lhs.parameters == rhs.parameters && lhs.expression == rhs.expression
	}
}
