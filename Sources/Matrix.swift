//
//  Matrix.swift
//  Symbols
//
//  Created by Palle Klewitz on 08.06.17.
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

public struct Index2D<IndexComponent: Strideable> {
	public let column: IndexComponent
	public let row: IndexComponent
	
	public init(column: IndexComponent, row: IndexComponent) {
		self.column = column
		self.row = row
	}
}

extension Index2D: Comparable {
	public static func <(lhs: Index2D<IndexComponent>, rhs: Index2D<IndexComponent>) -> Bool {
		return lhs.row < rhs.row || (lhs.row == rhs.row && lhs.column < rhs.column)
	}
	
	public static func ==(lhs: Index2D<IndexComponent>, rhs: Index2D<IndexComponent>) -> Bool {
		return lhs.column == rhs.column && lhs.row == rhs.row
	}
}

public struct Matrix<_Element>: Collection {
	public typealias Element = _Element
	public typealias Index = Index2D<Int>
	public typealias SubSequence = SubMatrix<Element>
	
	public var startIndex: Index2D<Int> {
		return Index2D(column: 0, row: 0)
	}
	
	public var endIndex: Index2D<Int> {
		return Index2D(column: width - 1, row: height - 1)
	}
	
	public let width: Int
	public let height: Int
	
	private var elements: [Element]
	
	public func index(after i: Index2D<Int>) -> Index2D<Int> {
		return i.column + 1 >= width ? Index2D(column: 0, row: i.row + 1) : Index2D(column: i.column + 1, row: i.row)
	}
	
	public subscript (index: Index2D<Int>) -> Element {
		get {
			return elements[index.column + index.row * width]
		}
		
		set (new) {
			elements[index.column + index.row * width] = new
		}
	}
	
	public init(repeating element: Element, width: Int, height: Int) {
		self.elements = [Element](repeating: element, count: width * height)
		self.width = width
		self.height = height
	}
}

public struct SubMatrix<_Element>: Collection {
	public typealias Element = _Element
	public typealias Index = Index2D<Int>
	public typealias SubSequence = SubMatrix<Element>
	
	public let startIndex: Index2D<Int>
	public let endIndex: Index2D<Int>
	
	public var width: Int {
		return endIndex.column - startIndex.column
	}
	
	public var height: Int {
		return endIndex.row - startIndex.row
	}
	
	private let base: Matrix<_Element>
	
	public func index(after i: Index2D<Int>) -> Index2D<Int> {
		return i.column + 1 >= endIndex.column ? Index2D(column: 0, row: i.row + 1) : Index2D(column: i.column + 1, row: i.row)
	}
	
	public subscript (index: Index2D<Int>) -> Element {
		return base[Index2D(column: index.column + startIndex.column, row: index.row + startIndex.row)]
	}
}
