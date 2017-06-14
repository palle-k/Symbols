//
//  Evaluation.swift
//  SymbolicMath
//
//  Created by Palle Klewitz on 30.05.17.
//
//

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
			return .exp(base.replacing(variable: variable, with: expression), exponent.replacing(variable: variable, with: expression))
			
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
			return .function(parameters.map {$0.replacing(variable: variable, with: expression)}, function)
			
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
			return try SymbolicMath.log(expr.evaluated(variables: variables, functions: functions))
			
		case .sin(let expr):
			return try SymbolicMath.sin(expr.evaluated(variables: variables, functions: functions))
			
		case .cos(let expr):
			return try SymbolicMath.cos(expr.evaluated(variables: variables, functions: functions))
			
		case .tan(let expr):
			return try SymbolicMath.tan(expr.evaluated(variables: variables, functions: functions))
			
		case .asin(let expr):
			return try SymbolicMath.asin(expr.evaluated(variables: variables, functions: functions))
			
		case .acos(let expr):
			return try SymbolicMath.acos(expr.evaluated(variables: variables, functions: functions))
			
		case .atan(let expr):
			return try SymbolicMath.atan(expr.evaluated(variables: variables, functions: functions))
			
		case .sinh(let expr):
			return try SymbolicMath.sinh(expr.evaluated(variables: variables, functions: functions))
			
		case .cosh(let expr):
			return try SymbolicMath.cosh(expr.evaluated(variables: variables, functions: functions))
			
		case .tanh(let expr):
			return try SymbolicMath.tanh(expr.evaluated(variables: variables, functions: functions))
			
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
			return try SymbolicMath.abs(expr.evaluated(variables: variables, functions: functions))
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
				factors.append(.exp(.variable(variable), .number(.real(.whole(count)))))
			}
			return .multiply(factors)
			
		case .exp(.exp(let epxr, let inner), let outer):
			fatalError()
			
		default:
			return self
		}
	}
}
