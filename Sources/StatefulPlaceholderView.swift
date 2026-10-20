//
// StatefulUI
// Copyright © 2024 Wisemen
//

import UIKit

public typealias StatefulPlaceholderViewHandler = () -> Void

public protocol StatefulPlaceholderView {
	/// Defines the insets to apply when presented via the `StatefulViewController`
	/// Return insets here in order to inset the current placeholder view from the edges
	/// of the parent view.
	func placeholderViewInsets() -> UIEdgeInsets

	/// Configures an update handler so changes can be observed by the view state machine
	/// By default this implementation does nothing
	func configure(updateHandler: StatefulPlaceholderViewHandler?)
}

public extension StatefulPlaceholderView {
	func placeholderViewInsets() -> UIEdgeInsets {
		return .zero
	}

	func configure(updateHandler: StatefulPlaceholderViewHandler?) { }
}
