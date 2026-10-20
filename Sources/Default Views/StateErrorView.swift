//
// StatefulUI
// Copyright © 2024 Wisemen
//

import IBAnimatable
import Reusable
import UIKit

public final class StateErrorView: UIView {
	// swiftlint:disable private_outlet
	@IBOutlet public var imageView: UIImageView!
	@IBOutlet public var titleLabel: UILabel!
	@IBOutlet public var subtitleLabel: UILabel!
	@IBOutlet public var button: AnimatableButton!
	// swiftlint:enable private_outlet

	private var placeholderUpdateHandler: StatefulPlaceholderViewHandler?

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

	@objc public dynamic var titleFont: UIFont = .preferredFont(forTextStyle: .headline) {
		didSet { titleLabel.font = titleFont }
	}

	@objc public dynamic var subtitleFont: UIFont = .preferredFont(forTextStyle: .subheadline) {
		didSet { subtitleLabel.font = subtitleFont }
	}

	@objc public dynamic var edgeInsets = UIEdgeInsets(top: 20, left: 30, bottom: 20, right: 30) {
		didSet {
			if edgeInsets != oldValue {
				placeholderUpdateHandler?()
			}
		}
	}

	@IBAction private func tappedButton() {
		delegate?.tappedPlaceholderButton(in: self)
	}

	public override func awakeFromNib() {
		super.awakeFromNib()

		titleLabel.textColor = titleColor
		subtitleLabel.textColor = subtitleColor
		button.backgroundColor = buttonBackgroundColor
		titleLabel.font = titleFont
		subtitleLabel.font = subtitleFont
	}
}

extension StateErrorView: NibReusable {
	public static var nib: UINib {
		return UINib(nibName: String(describing: self), bundle: .resources)
	}
}

extension StateErrorView: StatefulPlaceholderView {
	public func placeholderViewInsets() -> UIEdgeInsets {
		return edgeInsets
	}
	
	public func configure(updateHandler: StatefulPlaceholderViewHandler?) {
		placeholderUpdateHandler = updateHandler
	}
}

// MARK: Easy initializer

extension StateErrorView {
	public static func load(image: UIImage? = nil, title: String = "", subtitle: String = StatefulUIStrings.Message.error, buttonTitle: String = StatefulUIStrings.Button.refresh, delegate: PlaceholderViewDelegate? = nil) -> StateErrorView {
		let view = loadFromNib()
		view.configure(image: image, title: title, subtitle: subtitle, buttonTitle: buttonTitle, delegate: delegate)
		return view
	}

	public func configure(image: UIImage? = nil, title: String = "", subtitle: String = StatefulUIStrings.Message.error, buttonTitle: String = StatefulUIStrings.Button.refresh, delegate: PlaceholderViewDelegate? = nil) {
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
