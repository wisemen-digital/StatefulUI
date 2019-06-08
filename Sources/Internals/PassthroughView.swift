//
//  PassthroughView.swift
//  StatefulUI
//
//  Created by David Jennes on 02/04/2019.
//  Copyright © 2019 Appwise. All rights reserved.
//

import UIKit

final class PassthroughView: UIView {
	override init(frame: CGRect) {
		super.init(frame: frame)

		autoresizingMask = [.flexibleWidth, .flexibleHeight]
		backgroundColor = .clear
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override var frame: CGRect {
		set {
			// ensure the view isn't weirdly offset inside scrollviews
			if #available(iOS 11.0, *), let superview = superview as? UIScrollView {
				var frame = superview.bounds
				frame.origin = .zero
				frame.size.height -= superview.safeAreaInsets.top + superview.safeAreaInsets.bottom
				super.frame = frame
			} else {
				super.frame = newValue
			}
		}
		get {
			return super.frame
		}
	}

	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		for view in subviews {
			if !view.isHidden, view.alpha > 0, view.isUserInteractionEnabled, view.point(inside: convert(point, to: view), with: event) {
				return true
			}
		}
		return false
	}
}
