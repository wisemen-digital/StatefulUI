//
// StatefulUI
// Copyright © 2024 Wisemen
//

import UIKit

public protocol StatefulPlaceholderView {
	/// Defines the insets to apply when presented via the `StatefulViewController`
	/// Return insets here in order to inset the current placeholder view from the edges
	/// of the parent view.
	func placeholderViewInsets() -> UIEdgeInsets
}

public extension StatefulPlaceholderView {
	func placeholderViewInsets() -> UIEdgeInsets {
		return UIEdgeInsets()
	}
}
