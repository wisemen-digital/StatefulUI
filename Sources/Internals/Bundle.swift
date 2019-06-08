//
//  Bundle.swift
//  StatefulUI
//
//  Created by David Jennes on 08/06/2019.
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
