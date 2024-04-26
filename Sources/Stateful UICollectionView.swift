//
// StatefulUI
// Copyright © 2024 Wisemen
//

import UIKit

public extension StatefulViewController where Self: UICollectionViewController {
	var contentView: UIView {
		return collectionView
	}

	func hasContent() -> Bool {
		return collectionView.isNotEmpty
	}
}

public extension StatefulViewController where Self: UICollectionView {
	var contentView: UIView {
		return self
	}

	func hasContent() -> Bool {
		return isNotEmpty
	}
}

private extension UICollectionView {
	var isNotEmpty: Bool {
		guard let source = dataSource else { return false }

		let sections = source.numberOfSections?(in: self) ?? 0
		for section in 0..<sections where source.collectionView(self, numberOfItemsInSection: section) > 0 {
			return true
		}

		return false
	}
}
