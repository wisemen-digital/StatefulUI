//
//  StateLoadingView.swift
//  StatefulUI
//
//  Created by David Jennes on 02/04/2019.
//  Copyright © 2019 Appwise. All rights reserved.
//

import Reusable
import UIKit

public final class StateLoadingView: UIView {
	// swiftlint:disable private_outlet
	@IBOutlet public var activityIndicator: UIActivityIndicatorView?
	@IBOutlet public var titleLabel: UILabel?
	@IBOutlet public var subtitleLabel: UILabel?
	// swiftlint:enable private_outlet

	@objc public dynamic var activityIndicatorColor: UIColor? = .gray {
		didSet { activityIndicator?.color = activityIndicatorColor }
	}

	@objc public dynamic var titleColor: UIColor? = .black {
		didSet { titleLabel?.textColor = titleColor }
	}

	@objc public dynamic var subtitleColor: UIColor? = .black {
		didSet { subtitleLabel?.textColor = subtitleColor }
	}

	@objc public dynamic var edgeInsets = UIEdgeInsets(top: 20, left: 30, bottom: 20, right: 30)
}

extension StateLoadingView: NibReusable {
	public static var nib: UINib {
		return UINib(nibName: String(describing: self), bundle: .resources)
	}
}

extension StateLoadingView: StatefulPlaceholderView {
	public func placeholderViewInsets() -> UIEdgeInsets {
		return edgeInsets
	}
}

// MARK: Easy initializer

extension StateLoadingView {
	public static func load(title: String = "", subtitle: String = StatefulUIStrings.Message.loading) -> StateLoadingView {
		let view = loadFromNib()
		view.configure(title: title, subtitle: subtitle)
		return view
	}

	public func configure(title: String = "", subtitle: String = StatefulUIStrings.Message.loading) {
		titleLabel?.text = title
		titleLabel?.isHidden = title.isEmpty

		subtitleLabel?.text = subtitle
		subtitleLabel?.isHidden = subtitle.isEmpty
	}
}
