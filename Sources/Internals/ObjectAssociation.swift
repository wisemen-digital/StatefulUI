//
//  ObjectAssociation.swift
//  StatefulUI
//
//  Created by David Jennes on 20/05/2019.
//  Copyright © 2019 Appwise. All rights reserved.
//

import Foundation

final class ObjectAssociation<T: AnyObject> {
	private let policy: objc_AssociationPolicy

	init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
		self.policy = policy
	}

	subscript(index: AnyObject) -> T? {
		get {
			return objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as? T
		}
		set {
			objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy)
		}
	}
}
