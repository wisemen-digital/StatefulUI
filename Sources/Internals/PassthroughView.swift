//
// StatefulUI
// Copyright © 2024 Wisemen
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

	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		for view in subviews {
			if !view.isHidden, view.alpha > 0, view.isUserInteractionEnabled, view.point(inside: convert(point, to: view), with: event) {
				return true
			}
		}
		return false
	}
	
	// MARK: - Positioning listeners
	
	override var frame: CGRect {
		didSet { updatePositioning() }
	}

	override var bounds: CGRect {
		didSet { updatePositioning() }
	}

	override var center: CGPoint {
		didSet { updatePositioning() }
	}

	override func willMove(toSuperview newSuperview: UIView?) {
		super.willMove(toSuperview: newSuperview)
		updatePositioning()
	}

	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		updatePositioning()
	}

	override func willMove(toWindow newWindow: UIWindow?) {
		super.willMove(toWindow: newWindow)
		updatePositioning()
	}

	override func didMoveToWindow() {
		super.didMoveToWindow()
		updatePositioning()
	}

	override func layoutMarginsDidChange() {
		super.layoutMarginsDidChange()
		updatePositioning()
	}

	@available(iOS 11.0, tvOS 11.0, *)
	override func safeAreaInsetsDidChange() {
		super.safeAreaInsetsDidChange()
		updatePositioning()
	}

	private func updatePositioning() {
		DispatchQueue.main.async {
			var frame = self.superview?.bounds ?? .zero

			if let superview = self.superview as? UIScrollView {
				if #available(iOS 11.0, *) {
					frame = frame.inset(by: superview.safeAreaInsets)
				} else {
					frame = frame.inset(by: superview.contentInset)
				}
			}

			if frame != self.frame {
				super.frame = frame
			}
		}
	}
}

