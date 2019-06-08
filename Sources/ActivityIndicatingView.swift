//
//  ActivityIndicatingView.swift
//  StatefulUI
//
//  Created by David Jennes on 24/01/2019.
//  Copyright © 2019 Appwise. All rights reserved.
//

import UIKit

public protocol ActivityIndicatingView: AnyObject {
	func startAnimating()
	func stopAnimating()

	var isAnimating: Bool { get }
}

extension UIActivityIndicatorView: ActivityIndicatingView {
}
