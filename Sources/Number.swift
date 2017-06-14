//
//  Number.swift
//  SymbolicMath
//
//  Created by Palle Klewitz on 30.05.17.
//
//

import Foundation

//TODO: Rational numbers
public enum Number {
	case real(Scalar)
	case imaginary(Scalar)
	case complex(Scalar, Scalar)
}

public extension Number {
	public static var i: Number {
		return .imaginary(1)
	}
	
	public static var e: Number {
		return .real(2.718281828459045235360287471352662497757247093699959574966)
	}
	
	public static var pi: Number {
		return .real(.real(Double.pi))
	}
}

extension Number {
	func simplified() -> Number {
		switch self {
		case .complex(let real, let imaginary) where imaginary == 0:
			return .real(real)
			
		case .complex(let real, let imaginary) where real == 0:
			return .imaginary(imaginary)
			
		default:
			return self
		}
	}
}

extension Number: ExpressibleByIntegerLiteral {
	public typealias IntegerLiteralType = Int
	
	public init(integerLiteral value: IntegerLiteralType) {
		self = .real(.whole(value))
	}
}

extension Number: ExpressibleByFloatLiteral {
	public typealias FloatLiteralType = Double
	
	public init(floatLiteral value: FloatLiteralType) {
		self = .real(.real(value))
	}
}

extension Number: Equatable {
	public static func == (lhs: Number, rhs: Number) -> Bool {
		switch (lhs, rhs) {
		case (.real(let l), .real(let r)):
			return l == r
			
		case (.real(let l), .imaginary(let r)):
			return l == 0 && r == 0
			
		case (.imaginary(let l), .real(let r)):
			return l == 0 && r == 0
			
		case (.imaginary(let l), .imaginary(let r)):
			return l == r
			
		case (.real(let l), .complex(let rr, let ri)):
			return ri == 0 && l == rr
			
		case (.imaginary(let l), .complex(let rr, let ri)):
			return rr == 0 && l == ri
			
		case (.complex(let lr, let li), .real(let r)):
			return li == 0 && lr == r
			
		case (.complex(let lr, let li), .imaginary(let r)):
			return lr == 0 && li == r
			
		case (.complex(let lr, let li), .complex(let rr, let ri)):
			return lr == rr && li == ri
		}
	}
}

extension Number: CustomStringConvertible {
	public var description: String {
		switch self {
		case .real(let r):
			return r.description
			
		case .imaginary(let i) where i == 0:
			return "0"
			
		case .imaginary(let i) where i == 1:
			return "i"
			
		case .imaginary(let i) where i == -1:
			return "-i"
			
		case .imaginary(let i):
			return "\(i) * i"
			
		case .complex(let r, let i):
			return "\(r.description) + \(i.description) * i"
		}
	}
}

struct NumberComparisonError: Error {
	
}

extension Number {
	public static func compare(_ lhs: Number, _ rhs: Number) throws -> ComparisonResult {
		switch (lhs, rhs) {
		case (.real(let l), .real(let r)) where l < r,
		     (.imaginary(let l), .imaginary(let r)) where l < r:
			return ComparisonResult.orderedAscending
			
		case (.real(let l), .real(let r)) where l == r,
		     (.imaginary(let l), .imaginary(let r)) where l == r:
			return ComparisonResult.orderedSame
			
		case (.real(let l), .real(let r)) where l > r,
		     (.imaginary(let l), .imaginary(let r)) where l > r:
			return ComparisonResult.orderedDescending
			
		default:
			throw NumberComparisonError()
		}
	}
}

public prefix func - (value: Number) -> Number {
	switch value {
	case .real(let r):
		return .real(-r)
		
	case .imaginary(let i):
		return .imaginary(-i)
		
	case .complex(let r, let i):
		return .complex(-r, -i)
	}
}

public func + (lhs: Number, rhs: Number) -> Number {
	switch (lhs, rhs) {
	case (.real(let l), .real(let r)):
		return .real(l + r)
		
	case (.real(let l), .imaginary(let r)):
		return .complex(l, r)
		
	case (.imaginary(let l), .real(let r)):
		return .complex(r, l)
		
	case (.imaginary(let l), .imaginary(let r)):
		return .imaginary(l + r)
		
	case (.real(let l), .complex(let rr, let ri)):
		return Number.complex(l + rr, ri).simplified()
		
	case (.imaginary(let l), .complex(let rr, let ri)):
		return Number.complex(rr, l + ri).simplified()
		
	case (.complex(let lr, let li), .real(let r)):
		return Number.complex(lr + r, li)
		
	case (.complex(let lr, let li), .imaginary(let r)):
		return Number.complex(lr, li + r).simplified()
		
	case (.complex(let lr, let li), .complex(let rr, let ri)):
		return Number.complex(lr + rr, li + ri).simplified()
	}
}

public func - (lhs: Number, rhs: Number) -> Number {
	return lhs + -rhs
}

public func * (lhs: Number, rhs: Number) -> Number {
	switch (lhs, rhs) {
	case (.real(let l), .real(let r)):
		return .real(l * r)
		
	case (.real(let l), .imaginary(let r)):
		return .imaginary(l * r)
		
	case (.imaginary(let l), .real(let r)):
		return .imaginary(l * r)
		
	case (.imaginary(let l), .imaginary(let r)):
		return .real(-l * r)
		
	case (.real(let l), .complex(let rr, let ri)):
		return Number.complex(l * rr, l * ri).simplified()
		
	case (.imaginary(let l), .complex(let rr, let ri)):
		return Number.complex(-l * ri, l * rr).simplified()
		
	case (.complex(let lr, let li), .real(let r)):
		return Number.complex(lr * r, li * r)
		
	case (.complex(let lr, let li), .imaginary(let r)):
		return Number.complex(-li * r, lr * r).simplified()
		
	case (.complex(let lr, let li), .complex(let rr, let ri)):
		return Number.complex(lr * rr - li * ri, lr * ri + li * rr).simplified()
	}
}

public func / (lhs: Number, rhs: Number) -> Number {
	switch (lhs, rhs) {
	case (.real(let l), .real(let r)):
		return .real(l / r)
		
	case (.real(let l), .imaginary(let r)):
		return .imaginary(-l / r)
		
	case (.imaginary(let l), .real(let r)):
		return .imaginary(l / r)
		
	case (.imaginary(let l), .imaginary(let r)):
		return .real(l / r)
		
	case (.real(let l), .complex(let rr, let ri)):
		return ((.real(l) * Number.complex(rr, -ri).simplified()) / (Number.complex(rr, ri) * Number.complex(rr, -ri)).simplified()).simplified()
		
	case (.imaginary(let l), .complex(let rr, let ri)):
		return ((.imaginary(l) * Number.complex(rr, -ri).simplified()) / (Number.complex(rr, ri) * Number.complex(rr, -ri)).simplified()).simplified()
		
	case (.complex(let lr, let li), .real(let r)):
		return Number.complex(lr / r, li / r)
		
	case (.complex(let lr, let li), .imaginary(let r)):
		return Number.complex(li / r, -lr / r).simplified()
		
	case (.complex(let lr, let li), .complex(let rr, let ri)):
		return ((.complex(lr, li) * Number.complex(rr, -ri).simplified()) / (Number.complex(rr, ri) * Number.complex(rr, -ri)).simplified()).simplified()
	}
}

public func ** (lhs: Number, rhs: Number) -> Number {
	
	switch (lhs, rhs) {
	case (.real(let l), .real(let r)):
		return .real(l ** r)
		
	case (.real(let l), .imaginary(let r)):
		return exp(log(.real(l)) * .imaginary(r))

//	case (.imaginary(let l), .real(let r)):
//		return .imaginary(l / r)
//		
//	case (.imaginary(let l), .imaginary(let r)):
//		return .real(l / r)
//		
//	case (.real(let l), .complex(let rr, let ri)):
//		return ((.real(l) * Number.complex(rr, -ri).simplified()) / (Number.complex(rr, ri) * Number.complex(rr, -ri)).simplified()).simplified()
//		
//	case (.imaginary(let l), .complex(let rr, let ri)):
//		return ((.imaginary(l) * Number.complex(rr, -ri).simplified()) / (Number.complex(rr, ri) * Number.complex(rr, -ri)).simplified()).simplified()
//		
//	case (.complex(let lr, let li), .real(let r)):
//		return Number.complex(lr / r, li / r)
//		
//	case (.complex(let lr, let li), .imaginary(let r)):
//		return Number.complex(li / r, -lr / r).simplified()
//		
//	case (.complex(let lr, let li), .complex(let rr, let ri)):
//		return .real(lr * lr + li * li) ** 2
		
	default: fatalError()
	}
}

public func pow(lhs: Number, rhs: Number) -> Number {
	return lhs ** rhs
}

public func arg(_ value: Number) -> Number {
	switch value {
	case .real(let real):
		return .real(.real(real < 0 ? Double.pi : 0.0))
		
	case .imaginary(let imaginary):
		return .real(.real((imaginary < 0 ? 3.0 / 2.0 : 1.0 / 2.0) * Double.pi))
		
	case .complex(let real, let imaginary):
		return .real(.real(atan2(real.doubleValue, imaginary.doubleValue)))
	}
}

public func exp(_ value: Number) -> Number {
	switch value {
	case .real(let scalar):
		return .real(exp(scalar))
		
	case .imaginary(let scalar):
		return .complex(cos(scalar), sin(scalar))
		
	case .complex(let real, let imaginary):
		return .real(exp(real)) * exp(Number.imaginary(imaginary))
	}
}

public func log(_ value: Number) -> Number {
	switch value {
	case .real(let real):
		return .real(log(real))
		
	case .imaginary(let imaginary):
		fatalError()
		
	case .complex(let real, let imaginary):
		fatalError()
	}
}

public func abs(_ value: Number) -> Number {
	switch value {
	case .real(let real):
		return .real(abs(real))
		
	case .imaginary(let imaginary):
		return .real(abs(imaginary)) // sqrt(-imaginary * imaginary)
		
	case .complex(let real, let imaginary):
		return .real(sqrt(real * real + imaginary * imaginary))
	}
}

public func sin(_ value: Number) -> Number {
	switch value {
	case .real(let real):
		return .real(sin(real))
		
	default:
		fatalError()
	}
}

public func cos(_ value: Number) -> Number {
	switch value {
	case .real(let real):
		return .real(cos(real))
		
	default:
		fatalError()
	}
}

public func tan(_ value: Number) -> Number {
	switch value {
	case .real(let real):
		return .real(tan(real))
		
	default:
		fatalError()
	}
}

public func asin(_ value: Number) -> Number {
	switch value {
	case .real(let real):
		return .real(asin(real))
		
	default:
		fatalError()
	}
}

public func acos(_ value: Number) -> Number {
	switch value {
	case .real(let real):
		return .real(acos(real))
		
	default:
		fatalError()
	}
}

public func atan(_ value: Number) -> Number {
	switch value {
	case .real(let real):
		return .real(atan(real))
		
	default:
		fatalError()
	}
}

public func sinh(_ value: Number) -> Number {
	switch value {
	case .real(let real):
		return .real(sinh(real))
		
	default:
		fatalError()
	}
}

public func cosh(_ value: Number) -> Number {
	switch value {
	case .real(let real):
		return .real(cosh(real))
		
	default:
		fatalError()
	}
}

public func tanh(_ value: Number) -> Number {
	switch value {
	case .real(let real):
		return .real(tanh(real))
		
	default:
		fatalError()
	}
}

public func sqrt(_ value: Number) -> Number {
	switch value {
	case .real(let real):
		return .real(sqrt(real))
		
	default:
		fatalError()
	}
}
