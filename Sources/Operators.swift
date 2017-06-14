//
//  Operators.swift
//  Symbols
//
//  Created by Palle Klewitz on 30.05.17.
//
//


public func + (lhs: Expression, rhs: Expression) -> Expression {
	switch (lhs, rhs) {
	case (.add(let ls), .add(let rs)):
		return .add(ls + rs)
		
	case (.add(let ls), _):
		return .add(ls + [rhs])
		
	case (_, .add(let rs)):
		return .add([lhs] + rs)
		
	case (_, _):
		return .add([lhs, rhs])
	}
}

public func - (lhs: Expression, rhs: Expression) -> Expression {
	return .add([lhs, -rhs])
}

public func * (lhs: Expression, rhs: Expression) -> Expression {
	switch (lhs, rhs) {
	case (.multiply(let lf), .multiply(let rf)):
		return .multiply(lf + rf)
		
	case (.multiply(let lf), _):
		return .multiply(lf + [rhs])
		
	case (_, .multiply(let rf)):
		return .multiply([lhs] + rf)
		
	case (_, _):
		return .multiply([lhs, rhs])
	}
}

public func / (lhs: Expression, rhs: Expression) -> Expression {
	return .multiply([lhs, .invert(rhs)])
}

public prefix func - (value: Expression) -> Expression {
	return .negate(value)
}

public func ** (lhs: Expression, rhs: Expression) -> Expression {
	return .exp(lhs, rhs)
}

public func pow(_ base: Expression, _ exponent: Expression) -> Expression {
	return .exp(base, exponent)
}

public func log(_ expr: Expression) -> Expression {
	return .log(expr)
}

public func log(_ expr: Expression, base: Expression) -> Expression {
	return log(expr) / log(base)
}

public func sin(_ expr: Expression) -> Expression {
	return .sin(expr)
}

public func cos(_ expr: Expression) -> Expression {
	return .cos(expr)
}

public func tan(_ expr: Expression) -> Expression {
	return .tan(expr)
}

public func asin(_ expr: Expression) -> Expression {
	return .asin(expr)
}

public func acos(_ expr: Expression) -> Expression {
	return .acos(expr)
}

public func atan(_ expr: Expression) -> Expression {
	return .atan(expr)
}

public func sinh(_ expr: Expression) -> Expression {
	return .sinh(expr)
}

public func cosh(_ expr: Expression) -> Expression {
	return .cosh(expr)
}

public func tanh(_ expr: Expression) -> Expression {
	return .tanh(expr)
}

public func sqrt(_ expr: Expression) -> Expression {
	return .exp(expr, 0.5)
}
