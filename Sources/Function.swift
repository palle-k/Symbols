//
//  Function.swift
//  SymbolicMath
//
//  Created by Palle Klewitz on 30.05.17.
//
//

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
				return derive(expression: expr) / .exp(.cos(expr), 2)
				
			case .multiply(let expressions):
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
