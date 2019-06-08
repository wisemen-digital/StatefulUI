//
//  StatefulViewController (Implementation).swift
//  StatefulUI
//
//  Created by David Jennes on 30/03/2019.
//  Copyright © 2019 Appwise. All rights reserved.
//

import UIKit

/// Default implementation of StatefulViewController for UIViewController

// MARK: State machine

public extension StatefulViewController {
	var stateMachine: ViewStateMachine {
		if let result = AssociatedObjects.stateMachine[self] {
			return result
		} else {
			let result = ViewStateMachine(view: backingView)
			AssociatedObjects.stateMachine[self] = result
			initializeEmptyStateViews()
			ViewStateMachine.configureStatefulUIKitListeners(for: self)
			return result
		}
	}

	var currentState: StatefulViewControllerState {
		switch stateMachine.currentState {
		case .none:
			return .content
		case .view(let state):
			return state
		}
	}

	var lastState: StatefulViewControllerState {
		switch stateMachine.lastState {
		case .none:
			return .content
		case .view(let state):
			return state
		}
	}
}

// MARK: Views

public extension StatefulViewController {
	var loadingView: UIView? {
		get {
			return self[.loading]
		}
		set {
			self[.loading] = newValue
		}
	}

	var errorView: UIView? {
		get {
			return self[.error]
		}
		set {
			self[.error] = newValue
		}
	}

	var emptyView: UIView? {
		get {
			return self[.empty]
		}
		set {
			self[.empty] = newValue
		}
	}

	var subtleActivityIndicatorView: ActivityIndicatingView? {
		return nil
	}
}

private extension StatefulViewController {
	subscript(state: StatefulViewControllerState) -> UIView? {
		get {
			return stateMachine[state]
		}
		set {
			stateMachine[state] = newValue
		}
	}
}

// MARK: Transitions

public extension StatefulViewController {
	func setupInitialViewState(_ completion: (() -> Void)? = nil) {
		let isLoading = (lastState == .loading)
		let error: NSError? = (lastState == .error) ? NSError(domain: "be.appwise.StatefulViewController.ErrorDomain", code: -1, userInfo: nil) : nil
		transitionViewStates(loading: isLoading, error: error, animated: false, completion: completion)
	}

	func startLoading(animated: Bool = false, completion: (() -> Void)? = nil) {
		transitionViewStates(loading: true, animated: animated, completion: completion)
	}

	func endLoading(animated: Bool = true, error: Error? = nil, completion: (() -> Void)? = nil) {
		transitionViewStates(loading: false, error: error, animated: animated, completion: completion)
	}

	func transitionViewStates(loading: Bool = false, error: Error? = nil, animated: Bool = true, completion: (() -> Void)? = nil) {
		let newState: ViewStateMachineState

		// Update view for content (i.e. hide all placeholder views)
		if hasContent() {
			newState = .none

			// show/hide subtle indicator
			if loading {
				subtleActivityIndicatorView?.startAnimating()
			} else {
				subtleActivityIndicatorView?.stopAnimating()
			}

			// show unobstrusive error
			if let error = error {
				handleErrorWhenContentAvailable(error)
			}
		} else {
			// Update view for placeholder
			if loading {
				newState = .view(.loading)
			} else if error != nil {
				newState = .view(.error)
			} else {
				newState = .view(.empty)
			}

			// hide subtle indicator
			subtleActivityIndicatorView?.stopAnimating()
		}

		stateMachine.transitionToState(newState, animated: animated, completion: completion)
	}
}

// MARK: Content and error handling

public extension StatefulViewController {
	func hasContent() -> Bool {
		return true
	}

	func handleErrorWhenContentAvailable(_ error: Error) {
		// Default implementation does nothing.
	}
}

// MARK: - Association

private enum AssociatedObjects {
	static let stateMachine = ObjectAssociation<ViewStateMachine>()
}
