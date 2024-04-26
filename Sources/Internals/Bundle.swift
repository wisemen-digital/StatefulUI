//
// StatefulUI
// Copyright © 2024 Wisemen
//

import UIKit

extension Bundle {
	private static let bundle = Bundle(for: BundleToken.self)

	static let resources: Bundle = {
		guard let url = bundle.url(forResource: "StatefulUIResources", withExtension: "bundle"),
			let bundle = Bundle(url: url) else {
				fatalError("Can't find 'StatefulUIResources' resources bundle")
		}
		return bundle
	}()
}

private final class BundleToken {}
