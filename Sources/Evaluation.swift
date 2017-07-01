//
//  Evaluation.swift
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

enum EvaluationError: Error {
	case unboundVariable(Expression, String)
	case unknonwnFunction(Expression, String)
	case unsatisfiableBranch(Expression)
}

public extension Expression {
	public func replacing(variable: String, with expression: Expression) -> Expression {
		switch self {
		case .number(let number):
			return .number(number)
			
		case .constant(let name, let value):
			return .constant(name, value)
			
		case .invert(let expr):
			return .invert(expr.replacing(variable: variable, with: expression))
			
		case .negate(let expr):
			return .negate(expr.replacing(variable: variable, with: expression))
			
		case .multiply(let expressions):
			return .multiply(expressions.map {$0.replacing(variable: variable, with: expression)})
			
		case .add(let expressions):
			return .add(expressions.map {$0.replacing(variable: variable, with: expression)})
			
		case .exp(let base, let exponent):
			return .exp(base: base.replacing(variable: variable, with: expression), exponent: exponent.replacing(variable: variable, with: expression))
			
		case .log(let expr):
			return .log(expr.replacing(variable: variable, with: expression))
			
		case .sin(let expr):
			return .sin(expr.replacing(variable: variable, with: expression))
			
		case .cos(let expr):
			return .cos(expr.replacing(variable: variable, with: expression))
			
		case .tan(let expr):
			return .tan(expr.replacing(variable: variable, with: expression))
			
		case .sinh(let expr):
			return .sinh(expr.replacing(variable: variable, with: expression))
			
		case .cosh(let expr):
			return .cosh(expr.replacing(variable: variable, with: expression))
			
		case .tanh(let expr):
			return .tanh(expr.replacing(variable: variable, with: expression))
			
		case .asin(let expr):
			return .asin(expr.replacing(variable: variable, with: expression))
			
		case .acos(let expr):
			return .acos(expr.replacing(variable: variable, with: expression))
			
		case .atan(let expr):
			return .atan(expr.replacing(variable: variable, with: expression))
			
		case .function(let parameters, let function):
			return .function(parameters: parameters.map {$0.replacing(variable: variable, with: expression)}, name: function)
			
		case .variable(let v) where v == variable:
			return expression
			
		case .variable(let v):
			return .variable(v)
			
		case .branch(let options):
			return .branch(options.map({ (option) -> (Predicate, Expression) in
				return (option.0.replacing(variable: variable, with: expression), option.1.replacing(variable: variable, with: expression))
			}))
			
		case .abs(let expr):
			return .abs(expr.replacing(variable: variable, with: expression))
			
		case .sum(let parameter, let start, let end, let summand) where parameter == variable:
			return .sum(parameter: parameter, start: start.replacing(variable: variable, with: expression), end: end.replacing(variable: variable, with: expression), summand: summand)
			
		case .sum(parameter: let parameter, start: let start, end: let end, summand: let summand):
			return .sum(parameter: parameter, start: start.replacing(variable: variable, with: expression), end: end.replacing(variable: variable, with: expression), summand: summand.replacing(variable: variable, with: expression))
		}
	}
	
	public func evaluated(variables: [String: Number], functions: [String: Function] = [:]) throws -> Number {
		switch self {
		case .number(let number):
			return number
			
		case .constant(_, let number):
			return number
			
		case .negate(let expression):
			return try -expression.evaluated(variables: variables, functions: functions)
			
		case .invert(let expression):
			return try 1 / expression.evaluated(variables: variables, functions: functions)
			
		case .add(let summands):
			return try summands.map {try $0.evaluated(variables: variables, functions: functions)}.reduce(0, +)
			
		case .multiply(let factors):
			return try factors.map {try $0.evaluated(variables: variables, functions: functions)}.reduce(1, *)
			
		case .exp(let base, let exponent):
			return try base.evaluated(variables: variables, functions: functions) ** exponent.evaluated(variables: variables, functions: functions)
			
		case .log(let expr):
			return try Symbols.log(expr.evaluated(variables: variables, functions: functions))
			
		case .sin(let expr):
			return try Symbols.sin(expr.evaluated(variables: variables, functions: functions))
			
		case .cos(let expr):
			return try Symbols.cos(expr.evaluated(variables: variables, functions: functions))
			
		case .tan(let expr):
			return try Symbols.tan(expr.evaluated(variables: variables, functions: functions))
			
		case .asin(let expr):
			return try Symbols.asin(expr.evaluated(variables: variables, functions: functions))
			
		case .acos(let expr):
			return try Symbols.acos(expr.evaluated(variables: variables, functions: functions))
			
		case .atan(let expr):
			return try Symbols.atan(expr.evaluated(variables: variables, functions: functions))
			
		case .sinh(let expr):
			return try Symbols.sinh(expr.evaluated(variables: variables, functions: functions))
			
		case .cosh(let expr):
			return try Symbols.cosh(expr.evaluated(variables: variables, functions: functions))
			
		case .tanh(let expr):
			return try Symbols.tanh(expr.evaluated(variables: variables, functions: functions))
			
		case .variable(let name):
			if let value = variables[name] {
				return value
			} else {
				throw EvaluationError.unboundVariable(self, name)
			}
			
		case .function(let parameters, let name):
			if let function = functions[name] {
				return try function.evaluated(parameters: parameters.map {try $0.evaluated(variables: variables, functions: functions)}, functions: functions)
			} else {
				throw EvaluationError.unknonwnFunction(self, name)
			}
			
		case .branch(let options):
			if let result = try options.first(where: { (option) -> Bool in
				return try option.0.evaluated(variables: variables, functions: functions)
			})?.1 {
				return try result.evaluated(variables: variables, functions: functions)
			} else {
				throw EvaluationError.unsatisfiableBranch(self)
			}
			
		case .abs(let expr):
			return try Symbols.abs(expr.evaluated(variables: variables, functions: functions))
			
		case .sum(let parameter, let start, let end, let summand):
			let start = try start.evaluated(variables: variables, functions: functions)
			let end = try end.evaluated(variables: variables, functions: functions)
			
		}
	}
	
	public var isEvaluatable: Bool {
		switch self {
		case .number(_):
			return true
			
		case .variable(_):
			return false
			
		case .constant(_, _):
			return true
			
		case .add(let expressions):
			return !expressions.contains(where: { (expr) -> Bool in
				return !expr.isEvaluatable
			})
			
		case .multiply(let expressions):
			return !expressions.contains(where: { (expr) -> Bool in
				return !expr.isEvaluatable
			})
			
		case .negate(let expr):
			return expr.isEvaluatable
			
		case .invert(let expr):
			return expr.isEvaluatable
			
		case .exp(let base, let exponent):
			return base.isEvaluatable && exponent.isEvaluatable
			
		case .log(let expr):
			return expr.isEvaluatable
			
		case .sin(let expr):
			return expr.isEvaluatable
			
		case .cos(let expr):
			return expr.isEvaluatable
			
		case .tan(let expr):
			return expr.isEvaluatable
			
		case .asin(let expr):
			return expr.isEvaluatable
			
		case .acos(let expr):
			return expr.isEvaluatable
			
		case .atan(let expr):
			return expr.isEvaluatable
			
		case .sinh(let expr):
			return expr.isEvaluatable
			
		case .cosh(let expr):
			return expr.isEvaluatable
			
		case .tanh(let expr):
			return expr.isEvaluatable
			
		case .abs(let expr):
			return expr.isEvaluatable
			
		case .function(_, _):
			return false
			
		case .branch(let options):
			return !options.contains(where: { option -> Bool in
				return !option.1.isEvaluatable
			})
			
		case .sum(let variable, let start, let end, let summand):
			return start.isEvaluatable && end.isEvaluatable && summand.replacing(variable: variable, with: 0).isEvaluatable
		}
	}
	
	public func simplified() -> Expression {
		switch self {
		case .negate(.negate(let expression)):
			return expression.simplified()
			
		case .negate(.number(.real(let scalar))) where scalar < 0:
			return .number(.real(-scalar))
			
		case .negate(.number(.imaginary(let scalar))) where scalar < 0:
			return .number(.imaginary(-scalar))
			
		case .negate(.number(.complex(let real, let imaginary))) where real < 0 && imaginary < 0:
			return .number(.complex(-real, -imaginary))
			
		case .multiply(let fs):
			var factors = fs.map {$0.simplified()}
			let variables = factors.flatMap { expression -> String? in
				if case .variable(let name) = expression {
					return name
				} else {
					return nil
				}
			}
			var occurences: [String: Int] = [:]
			for variable in variables {
				occurences[variable] = (occurences[variable] ?? 0) + 1
			}
			
			for (variable, count) in occurences where count > 1 {
				factors = factors.filter { expression -> Bool in
					if case .variable(let name) = expression, name == variable {
						return false
					} else {
						return true
					}
				}
				factors.append(.exp(base: .variable(variable), exponent: .number(.real(.whole(count)))))
			}
			return .multiply(factors)
			
//		case .exp(.exp(let epxr, let inner), let outer):
//			fatalError()
			
		default:
			return self
		}
	}
}
