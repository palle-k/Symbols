//
//  Operators.swift
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
