//
//  Predicate.swift
//  Symbols
//
//  Created by Palle Klewitz on 07.06.17.
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

public indirect enum Predicate {
	case `true`
	case `false`
	case all([Predicate])
	case any([Predicate])
	case not(Predicate)
	case lessThan(Expression, Expression)
	case greaterThan(Expression, Expression)
	case lessThanOrEqual(Expression, Expression)
	case greaterThanOrEqual(Expression, Expression)
	case equals([Expression])
	case same([Predicate])
}

public extension Predicate {
	public func replacing(variable: String, with expression: Expression) -> Predicate {
		switch self {
		case .true:
			return .true
			
		case .false:
			return .false
			
		case .all(let predicates):
			return .all(predicates.map({ (predicate) -> Predicate in
				predicate.replacing(variable: variable, with: expression)
			}))
			
		case .any(let predicates):
			return .any(predicates.map({ (predicate) -> Predicate in
				predicate.replacing(variable: variable, with: expression)
			}))
			
		case .not(let predicate):
			return .not(predicate.replacing(variable: variable, with: expression))
			
		case .lessThan(let lhs, let rhs):
			return .lessThan(lhs.replacing(variable: variable, with: expression), rhs.replacing(variable: variable, with: expression))
			
		case .greaterThan(let lhs, let rhs):
			return .greaterThan(lhs.replacing(variable: variable, with: expression), rhs.replacing(variable: variable, with: expression))
			
		case .lessThanOrEqual(let lhs, let rhs):
			return .lessThanOrEqual(lhs.replacing(variable: variable, with: expression), rhs.replacing(variable: variable, with: expression))
			
		case .greaterThanOrEqual(let lhs, let rhs):
			return .greaterThanOrEqual(lhs.replacing(variable: variable, with: expression), rhs.replacing(variable: variable, with: expression))
			
		case .equals(let expressions):
			return .equals(expressions.map({ expression -> Expression in
				return expression.replacing(variable: variable, with: expression)
			}))
			
		case .same(let predicates):
			return .same(predicates.map({ (predicate) -> Predicate in
				predicate.replacing(variable: variable, with: expression)
			}))
		}
	}
	
	public func evaluated(variables: [String: Number], functions: [String: Function]) throws -> Bool {
		switch self {
		case .all(let predicates):
			return try predicates.all({ predicate -> Bool in
				try predicate.evaluated(variables: variables, functions: functions)
			})
			
		case .any(let predicates):
			return try predicates.contains(where: { predicate -> Bool in
				try predicate.evaluated(variables: variables, functions: functions)
			})
			
		case .not(let predicate):
			return try !predicate.evaluated(variables: variables, functions: functions)
			
		case .lessThan(let lhs, let rhs):
			return try Number.compare(lhs.evaluated(variables: variables, functions: functions), rhs.evaluated(variables: variables, functions: functions)) == ComparisonResult.orderedAscending
			
		case .greaterThan(let lhs, let rhs):
			return try Number.compare(lhs.evaluated(variables: variables, functions: functions), rhs.evaluated(variables: variables, functions: functions)) == ComparisonResult.orderedDescending
			
		case .lessThanOrEqual(let lhs, let rhs):
			let result = try Number.compare(lhs.evaluated(variables: variables, functions: functions), rhs.evaluated(variables: variables, functions: functions))
			return result == ComparisonResult.orderedAscending || result == ComparisonResult.orderedSame
			
		case .greaterThanOrEqual(let lhs, let rhs):
			let result = try Number.compare(lhs.evaluated(variables: variables, functions: functions), rhs.evaluated(variables: variables, functions: functions))
			return result == ComparisonResult.orderedDescending || result == ComparisonResult.orderedSame
			
		case .equals(let expressions):
			let evaluated = try expressions.map({ expr -> Number in
				return try expr.evaluated(variables: variables, functions: functions)
			})
			return evaluated.all({ number -> Bool in
				return number == evaluated.first!
			})
			
		case .same(let predicates):
			let evaluated = try predicates.map({ pred -> Bool in
				return try pred.evaluated(variables: variables, functions: functions)
			})
			return evaluated.all({$0}) || evaluated.all({!$0})
			
		case .true:
			return true
			
		case .false:
			return false
		}
	}
	
	public var isEvaluatable: Bool {
		switch self {
		case .true:
			return true
			
		case .false:
			return true
			
		case .all(let predicates):
			return predicates.all { predicate -> Bool in
				predicate.isEvaluatable
			}
			
		case .any(let predicates):
			return predicates.all { predicate -> Bool in
				predicate.isEvaluatable
			}
			
		case .not(let predicate):
			return predicate.isEvaluatable
			
		case .lessThan(let lhs, let rhs):
			return lhs.isEvaluatable && rhs.isEvaluatable
			
		case .greaterThan(let lhs, let rhs):
			return lhs.isEvaluatable && rhs.isEvaluatable
			
		case .lessThanOrEqual(let lhs, let rhs):
			return lhs.isEvaluatable && rhs.isEvaluatable
			
		case .greaterThanOrEqual(let lhs, let rhs):
			return lhs.isEvaluatable && rhs.isEvaluatable
			
		case .equals(let expressions):
			return expressions.all { expression -> Bool in
				expression.isEvaluatable
			}
			
		case .same(let predicates):
			return predicates.all { predicate -> Bool in
				predicate.isEvaluatable
			}
		}
	}
}

extension Predicate: CustomStringConvertible {
	public var description: String {
		switch self {
		case .all(let predicates):
			return predicates.map { predicate -> String in
				"(\(predicate.description))"
			}.joined(separator: " && ")
			
		case .any(let predicates):
			return predicates.map { predicate -> String in
				"(\(predicate.description))"
			}.joined(separator: " || ")
			
		case .not(let predicate):
			return "!(\(predicate.description))"
			
		case .lessThan(let lhs, let rhs):
			return "(\(lhs.description)) < (\(rhs.description))"
			
		case .greaterThan(let lhs, let rhs):
			return "(\(lhs.description)) > (\(rhs.description))"
			
		case .lessThanOrEqual(let lhs, let rhs):
			return "(\(lhs.description)) <= (\(rhs.description))"
			
		case .greaterThanOrEqual(let lhs, let rhs):
			return "(\(lhs.description)) == (\(rhs.description))"
			
		case .equals(let expressions):
			return expressions.map { expression -> String in
				"(\(expression.description))"
			}.joined(separator: " == ")
			
		case .same(let predicates):
			return predicates.map { predicate -> String in
				"(\(predicate.description))"
			}.joined(separator: " <-> ")
			
		case .true:
			return "true"
			
		case .false:
			return "false"
		}
	}
}

extension Predicate: Equatable {
	public static func == (lhs: Predicate, rhs: Predicate) -> Bool {
		switch (lhs, rhs) {
		case (.true, .true):
			return true
			
		case (.false, .false):
			return true
			
		case (.all(let le), .all(let re)) where le == re:
			return true
			
		case (.any(let le), .any(let re)) where le == re:
			return true
			
		case (.not(let le), .not(let re)) where le == re:
			return true
			
		case (.lessThan(let ll, let lr), .lessThan(let rl, let rr)) where ll == rl && lr == rr:
			return true
			
		case (.lessThanOrEqual(let ll, let lr), .lessThanOrEqual(let rl, let rr)) where ll == rl && lr == rr:
			return true
			
		case (.greaterThan(let ll, let lr), .greaterThan(let rl, let rr)) where ll == rl && lr == rr:
			return true
			
		case (.greaterThanOrEqual(let ll, let lr), .greaterThanOrEqual(let rl, let rr)) where ll == rl && lr == rr:
			return true
			
		case (.equals(let le), .equals(let re)) where le == re:
			return true
			
		case (.same(let le), .same(let re)) where le == re:
			return true
			
		default:
			return false
		}
	}
}

extension Predicate: ExpressibleByBooleanLiteral {
	public typealias BooleanLiteralType = Bool
	
	public init(booleanLiteral value: Bool) {
		self = value ? .true : .false
	}
}

public extension Predicate {
	public func contains(variable: String) -> Bool {
		switch self {
		case .true:
			return false
			
		case .false:
			return false
			
		case .all(let predicates):
			return predicates.contains(where: { predicate -> Bool in
				return predicate.contains(variable: variable)
			})
			
		case .any(let predicates):
			return predicates.contains(where: { predicate -> Bool in
				return predicate.contains(variable: variable)
			})
			
		case .not(let predicate):
			return predicate.contains(variable: variable)
			
		case .lessThan(let lhs, let rhs):
			return lhs.contains(variable: variable) || rhs.contains(variable: variable)
			
		case .greaterThan(let lhs, let rhs):
			return lhs.contains(variable: variable) || rhs.contains(variable: variable)
			
		case .lessThanOrEqual(let lhs, let rhs):
			return lhs.contains(variable: variable) || rhs.contains(variable: variable)
			
		case .greaterThanOrEqual(let lhs, let rhs):
			return lhs.contains(variable: variable) || rhs.contains(variable: variable)
			
		case .equals(let expressions):
			return expressions.contains(where: { expression -> Bool in
				expression.contains(variable: variable)
			})
			
		case .same(let predicates):
			return predicates.contains(where: { predicate -> Bool in
				predicate.contains(variable: variable)
			})
		}
	}
}

public func && (lhs: Predicate, rhs: Predicate) -> Predicate {
	return .all([lhs, rhs])
}

public func || (lhs: Predicate, rhs: Predicate) -> Predicate {
	return .any([lhs, rhs])
}

public prefix func ! (value: Predicate) -> Predicate {
	return .not(value)
}

infix operator <->: ComparisonPrecedence

public func <-> (lhs: Predicate, rhs: Predicate) -> Predicate {
	return .same([lhs, rhs])
}

public func === (lhs: Expression, rhs: Expression) -> Predicate {
	return .equals([lhs, rhs])
}

public func < (lhs: Expression, rhs: Expression) -> Predicate {
	return .lessThan(lhs, rhs)
}

public func > (lhs: Expression, rhs: Expression) -> Predicate {
	return .greaterThan(lhs, rhs)
}

public func <= (lhs: Expression, rhs: Expression) -> Predicate {
	return .lessThanOrEqual(lhs, rhs)
}

public func >= (lhs: Expression, rhs: Expression) -> Predicate {
	return .greaterThanOrEqual(lhs, rhs)
}
