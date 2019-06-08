//
//  BackingViewProvider.swift
//  StatefulUI
//
//  Created by David Jennes on 02/04/2019.
//  Copyright © 2019 Appwise. All rights reserved.
//

import UIKit

/// Protocol to provide a backing view for that stateful view controller
public protocol BackingViewProvider {
	/// The backing view, usually a UIViewController's view.
	/// All placeholder views will be added to this view instance.
	var backingView: UIView { get }
}

// MARK: - Default Implementation

public extension BackingViewProvider where Self: UIViewController {
	var backingView: UIView {
		return view
	}
}

public extension BackingViewProvider where Self: UIView {
	var backingView: UIView {
		return self
	}
}
