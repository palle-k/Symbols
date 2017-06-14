//
//  Utility.swift
//  Symbols
//
//  Created by Palle Klewitz on 07.06.17.
//

import Foundation

extension Collection {
	func all(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
		return try self.reduce(true, { (acc, element) -> Bool in
			return try acc && predicate(element)
		})
	}
}
