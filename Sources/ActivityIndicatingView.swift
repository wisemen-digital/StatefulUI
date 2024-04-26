//
// StatefulUI
// Copyright © 2024 Wisemen
//

import UIKit

public protocol ActivityIndicatingView: AnyObject {
	func startAnimating()
	func stopAnimating()

	var isAnimating: Bool { get }
}

extension UIActivityIndicatorView: ActivityIndicatingView {
}
