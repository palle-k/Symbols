//
//  Vector.swift
//  Symbols
//
//  Created by Palle Klewitz on 26.06.17.
//


struct Vector: Collection {
	
	typealias Element = Expression
	typealias Index = Int
	
	private var expressions: [Expression]
	
	var startIndex: Int {
		return expressions.startIndex
	}
	
	var endIndex: Int {
		return expressions.endIndex
	}
	
	subscript (index: Index) -> Expression {
		get {
			return expressions[index]
		}
		
		set (new) {
			expressions[index] = new
		}
	}
	
	func index(after i: Int) -> Int {
		return i + 1
	}
}
