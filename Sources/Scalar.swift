//
//  Scalar.swift
//  SymbolicMath
//
//  Created by Palle Klewitz on 30.05.17.
//
//

import Foundation

public enum Scalar {
	case real(Double)
	case whole(Int)
}

extension Scalar {
	var doubleValue: Double {
		switch self {
		case .real(let real):
			return real
		
		case .whole(let whole):
			return Double(whole)
		}
	}
}

extension Scalar {
	var pi: Scalar {
		return .real(Double.pi)
	}
	
	var e: Scalar {
		return .real(2.718281828459045235360287471352662497757247093699959574966)
	}
}

extension Scalar: ExpressibleByFloatLiteral {
	public typealias FloatLiteralType = Double
	
	public init(floatLiteral value: FloatLiteralType) {
		self = .real(value)
	}
	
	public init(_ value: FloatLiteralType) {
		self = .real(value)
	}
}

extension Scalar: ExpressibleByIntegerLiteral {
	public typealias IntegerLiteralType = Int
	
	public init(integerLiteral value: IntegerLiteralType) {
		self = .whole(value)
	}
	
	public init(_ value: IntegerLiteralType) {
		self = .whole(value)
	}
}

extension Scalar: Equatable {
	public static func ==(lhs: Scalar, rhs: Scalar) -> Bool {
		switch (lhs, rhs) {
		case (.real(let l), .real(let r)):
			return l == r
			
		case (.real(let l), .whole(let r)):
			return l == Double(r)
			
		case (.whole(let l), .real(let r)):
			return Double(l) == r
			
		case (.whole(let l), .whole(let r)):
			return l == r
		}
	}
}

extension Scalar: Comparable {
	public static func < (lhs: Scalar, rhs: Scalar) -> Bool {
		switch (lhs, rhs) {
		case (.whole(let l), .whole(let r)):
			return l < r
			
		case (.whole(let l), .real(let r)):
			return Double(l) < r
			
		case (.real(let l), .whole(let r)):
			return l < Double(r)
			
		case (.real(let l), .real(let r)):
			return l < r
		}
	}
}

extension Scalar: CustomStringConvertible {
	public var description: String {
		switch self {
		case .real(let real):
			return real.description
			
		case .whole(let whole):
			return whole.description
		}
	}
}

public prefix func - (value: Scalar) -> Scalar {
	switch value {
	case .real(let r):
		return .real(-r)
		
	case .whole(let w):
		return .whole(-w)
	}
}

public func + (lhs: Scalar, rhs: Scalar) -> Scalar {
	switch (lhs, rhs) {
	case (.real(let l), .real(let r)):
		return .real(l + r)
		
	case (.real(let l), .whole(let r)):
		return .real(l + Double(r))
		
	case (.whole(let l), .real(let r)):
		return .real(Double(l) + r)
		
	case (.whole(let l), .whole(let r)):
		return .whole(l + r)
	}
}

public func * (lhs: Scalar, rhs: Scalar) -> Scalar {
	switch (lhs, rhs) {
	case (.real(let l), .real(let r)):
		return .real(l * r)
		
	case (.real(let l), .whole(let r)):
		return .real(l * Double(r))
		
	case (.whole(let l), .real(let r)):
		return .real(Double(l) * r)
		
	case (.whole(let l), .whole(let r)):
		return .whole(l * r)
	}
}

public func - (lhs: Scalar, rhs: Scalar) -> Scalar {
	return lhs + -rhs
}

public func / (lhs: Scalar, rhs: Scalar) -> Scalar {
	switch (lhs, rhs) {
	case (.real(let l), .real(let r)):
		return .real(l / r)
		
	case (.real(let l), .whole(let r)):
		return .real(l / Double(r))
		
	case (.whole(let l), .real(let r)):
		return .real(Double(l) / r)
		
	case (.whole(let l), .whole(let r)) where l % r == 0:
		return .whole(l / r)
		
	case (.whole(let l), .whole(let r)):
		return .real(Double(l) / Double(r))
	}
}

precedencegroup ExponentiationPrecedence {
	higherThan: MultiplicationPrecedence
}

infix operator ** : ExponentiationPrecedence

public func ** (lhs: Scalar, rhs: Scalar) -> Scalar {
	switch (lhs, rhs) {
	case (.whole(let base), .whole(let exponent)) where exponent > 0:
		return .whole((1 ... exponent).reduce(1, { acc, _ -> Int in
			return acc * base
		}))
		
	case (_, .whole(0)):
		return 1
		
	case (_, .real(0)):
		return 1
		
	case (.whole(let base), .whole(let exponent)):
		return .real(pow(Double(base), Double(exponent)))
		
	case (.whole(let base), .real(let exponent)):
		return .real(pow(Double(base), exponent))
		
	case (.real(let base), .whole(let exponent)):
		return .real(pow(base, Double(exponent)))
		
	case (.real(let base), .real(let exponent)):
		return .real(pow(base, exponent))
	}
}

public func pow(_ base: Scalar, _ exponent: Scalar) -> Scalar {
	return base ** exponent
}

public func exp(_ exponent: Scalar) -> Scalar {
	return .real(exp(exponent.doubleValue))
}

public func log(_ exponent: Scalar) -> Scalar {
	return .real(log(exponent.doubleValue))
}

public func sin(_ value: Scalar) -> Scalar {
	return .real(sin(value.doubleValue))
}

public func cos(_ value: Scalar) -> Scalar {
	return .real(cos(value.doubleValue))
}

public func tan(_ value: Scalar) -> Scalar {
	return .real(tan(value.doubleValue))
}

public func asin(_ value: Scalar) -> Scalar {
	return .real(asin(value.doubleValue))
}

public func acos(_ value: Scalar) -> Scalar {
	return .real(acos(value.doubleValue))
}

public func atan(_ value: Scalar) -> Scalar {
	return .real(atan(value.doubleValue))
}

public func sinh(_ value: Scalar) -> Scalar {
	return .real(sinh(value.doubleValue))
}

public func cosh(_ value: Scalar) -> Scalar {
	return .real(cosh(value.doubleValue))
}

public func tanh(_ value: Scalar) -> Scalar {
	return .real(tanh(value.doubleValue))
}

public func atan2(_ a: Scalar, _ b: Scalar) -> Scalar {
	return .real(atan2(a.doubleValue, b.doubleValue))
}

public func abs(_ value: Scalar) -> Scalar {
	switch value {
	case .real(let real):
		return .real(abs(real))
		
	case .whole(let whole):
		return .whole(abs(whole))
	}
}

public func sqrt(_ value: Scalar) -> Scalar {
	let res = sqrt(value.doubleValue)
	
	switch value {
	case .whole(let value):
		if Int(res) * Int(res) == value {
			return .whole(Int(res))
		} else {
			return .real(res)
		}
		
	case _:
		return .real(res)
	}
}