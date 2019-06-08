//
//  StatefulViewController (UITableView).swift
//  StatefulUI
//
//  Created by David Jennes on 02/04/2019.
//  Copyright © 2019 Appwise. All rights reserved.
//

import UIKit

public extension StatefulViewController where Self: UITableViewController {
	var contentView: UIView {
		return tableView
	}

	func hasContent() -> Bool {
		return tableView.isNotEmpty
	}
}

public extension StatefulViewController where Self: UITableView {
	var contentView: UIView {
		return self
	}

	func hasContent() -> Bool {
		return isNotEmpty
	}
}

private extension UITableView {
	var isNotEmpty: Bool {
		guard let source = dataSource else { return false }

		let sections = source.numberOfSections?(in: self) ?? 0
		for section in 0..<sections where source.tableView(self, numberOfRowsInSection: section) > 0 {
			return true
		}

		return false
	}
}
