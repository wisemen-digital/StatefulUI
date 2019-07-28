//
//  StateEmptyView.swift
//  StatefulUI
//
//  Created by David Jennes on 02/04/2019.
//  Copyright © 2019 Appwise. All rights reserved.
//

import IBAnimatable
import Reusable
import UIKit

public final class StateEmptyView: UIView {
	// swiftlint:disable private_outlet
	@IBOutlet public var imageView: UIImageView!
	@IBOutlet public var titleLabel: UILabel!
	@IBOutlet public var subtitleLabel: UILabel!
	@IBOutlet public var button: AnimatableButton!
	// swiftlint:enable private_outlet

	public weak var delegate: PlaceholderViewDelegate?

	@objc public dynamic var titleColor: UIColor? = .black {
		didSet { titleLabel.textColor = titleColor }
	}

	@objc public dynamic var subtitleColor: UIColor? = .black {
		didSet { subtitleLabel.textColor = subtitleColor }
	}

	@objc public dynamic var buttonBackgroundColor: UIColor? = .clear {
		didSet { button.backgroundColor = buttonBackgroundColor }
	}

	@objc public dynamic var edgeInsets = UIEdgeInsets(top: 20, left: 30, bottom: 20, right: 30)

	@IBAction private func tappedButton() {
		delegate?.tappedPlaceholderButton(in: self)
	}
}

extension StateEmptyView: NibReusable {
	public static var nib: UINib {
		return UINib(nibName: String(describing: self), bundle: .resources)
	}
}

extension StateEmptyView: StatefulPlaceholderView {
	public func placeholderViewInsets() -> UIEdgeInsets {
		return edgeInsets
	}
}

// MARK: Easy initializer

extension StateEmptyView {
	public static func load(image: UIImage? = nil, title: String = "", subtitle: String = "", buttonTitle: String = StatefulUIStrings.Button.refresh, delegate: PlaceholderViewDelegate? = nil) -> StateEmptyView {
		let view = loadFromNib()
		view.configure(image: image, title: title, subtitle: subtitle, buttonTitle: buttonTitle, delegate: delegate)
		return view
	}

	public func configure(image: UIImage? = nil, title: String = "", subtitle: String = "", buttonTitle: String = StatefulUIStrings.Button.refresh, delegate: PlaceholderViewDelegate? = nil) {
		imageView.image = image
		imageView.isHidden = image == nil

		titleLabel.text = title
		titleLabel.isHidden = title.isEmpty

		subtitleLabel.text = subtitle
		subtitleLabel.isHidden = subtitle.isEmpty

		button.setTitle(buttonTitle, for: .normal)
		button.isHidden = buttonTitle.isEmpty

		self.delegate = delegate
	}
}
