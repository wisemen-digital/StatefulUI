//
// StatefulUI
// Copyright © 2024 Wisemen
//

import UIKit

extension ViewStateMachine {
	static func configureStatefulUIKitListeners(for listener: StatefulViewController) {
		// execute swizzling ONLY once
		_ = swizzleMethodsOnlyOnce

		// configure delegate
		let object = AssociatedObjects.WeakStatefulViewController(object: listener)
		switch listener.contentView {
		case let view as UITableView:
			AssociatedObjects.listener[view] = object
		case let view as UICollectionView:
			AssociatedObjects.listener[view] = object
		default:
			break
		}
	}

	private static let swizzleMethodsOnlyOnce: Void = {
		swizzleMethod(UITableView.self, from: #selector(UITableView.reloadData), to: #selector(UITableView.statefulTableView_reloadData))
		swizzleMethod(UITableView.self, from: #selector(UITableView.endUpdates), to: #selector(UITableView.statefulTableView_endUpdates))
		swizzleMethod(UICollectionView.self, from: #selector(UICollectionView.reloadData), to: #selector(UICollectionView.statefulCollectionView_reloadData))
		swizzleMethod(UICollectionView.self, from: #selector(UICollectionView.performBatchUpdates(_:completion:)), to: #selector(UICollectionView.statefulCollectionView_performBatchUpdates))
	}()

	private static func swizzleMethod(_ class: AnyClass, from selector1: Selector, to selector2: Selector) {
		guard let method1: Method = class_getInstanceMethod(`class`, selector1),
			let method2: Method = class_getInstanceMethod(`class`, selector2) else { return }

		if class_addMethod(`class`, selector1, method_getImplementation(method2), method_getTypeEncoding(method2)) {
			class_replaceMethod(`class`, selector2, method_getImplementation(method1), method_getTypeEncoding(method1))
		} else {
			method_exchangeImplementations(method1, method2)
		}
	}
}

// MARK: - UITableView overrides

private extension UITableView {
	@objc
	func statefulTableView_reloadData() {
		statefulTableView_reloadData()
		AssociatedObjects.listener[self]?.object?.setupInitialViewState()
	}

	@objc
	func statefulTableView_endUpdates() {
		statefulTableView_endUpdates()
		AssociatedObjects.listener[self]?.object?.setupInitialViewState()
	}
}

// MARK: - UICollectionView overrides

private extension UICollectionView {
	@objc
	func statefulCollectionView_reloadData() {
		statefulCollectionView_reloadData()
		AssociatedObjects.listener[self]?.object?.setupInitialViewState()
	}

	@objc
	func statefulCollectionView_performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
		statefulCollectionView_performBatchUpdates(updates) { (completed: Bool) in
			AssociatedObjects.listener[self]?.object?.setupInitialViewState()
			completion?(completed)
		}
	}
}

// MARK: - Association

private enum AssociatedObjects {
	final class WeakStatefulViewController {
		weak var object: StatefulViewController?

		init(object: StatefulViewController) {
			self.object = object
		}
	}

	static let listener = ObjectAssociation<WeakStatefulViewController>()
}
