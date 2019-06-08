//
//  StatefulPlaceholderView.swift
//  StatefulUI
//
//  Created by David Jennes on 30/03/2019.
//  Copyright © 2019 Appwise. All rights reserved.
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
