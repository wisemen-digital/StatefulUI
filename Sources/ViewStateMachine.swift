//
// StatefulUI
// Copyright © 2024 Wisemen
//

import UIKit

/// Represents the state of the view state machine
public enum ViewStateMachineState: Equatable {
	/// No view shown
	case none
	/// View with specific key is shown
	case view(StatefulViewControllerState)
}

///
/// A state machine that manages a set of views.
///
/// There are two possible states:
/// 		* Show a specific placeholder view, represented by a state
/// 		* Hide all managed views
///
public class ViewStateMachine {
	private var viewStore: [StatefulViewControllerState: UIView]
	private let queue: OperationQueue = {
		let queue = OperationQueue()
		queue.name = "be.appwise.viewStateMachine.queue"
		queue.qualityOfService = .userInteractive
		queue.maxConcurrentOperationCount = 1
		return queue
	}()

	/// An invisible container view that gets added to the view.
	/// The placeholder views will be added to the containerView.
	///
	/// view
	///   \_ containerView
	///         \_ error | loading | empty view
	private lazy var containerView = PassthroughView(frame: .zero)

	/// Views detached from their state are marked to be removed from the view hierarchy.
	/// Removal happens on the next state transition.
	private var pendingViews: [UIView] = []

	/// The view that should act as the superview for any added views
	public weak var view: UIView?

	/// The current display state of views
	public private(set) var currentState: ViewStateMachineState = .none

	/// The last state that was enqueued
	public private(set) var lastState: ViewStateMachineState = .none

	// MARK: Init

	///  Designated initializer.
	///
	/// - parameter view:		The view that should act as the superview for any added views
	/// - parameter states:		A dictionary of states
	///
	/// - returns:			A view state machine with the given views for states
	///
	public init(view: UIView, states: [StatefulViewControllerState: UIView]) {
		self.view = view
		viewStore = states
	}

	/// - parameter view:		The view that should act as the superview for any added views
	///
	/// - returns:			A view state machine
	///
	public convenience init(view: UIView) {
		self.init(view: view, states: [:])
	}

	deinit {
		queue.cancelAllOperations()
	}

	// MARK: Add and remove view states

	/// - returns: the view for a given state
	public func viewForState(_ state: StatefulViewControllerState) -> UIView? {
		return viewStore[state]
	}

	/// Associates a view for the given state
	public func addView(_ view: UIView, forState state: StatefulViewControllerState) {
		if let detachedView = viewStore[state], detachedView != view {
			pendingViews.append(detachedView)
		}
		viewStore[state] = view
	}

	///  Removes the view for the given state
	public func removeViewForState(_ state: StatefulViewControllerState) {
		if let detachedView = viewStore[state], detachedView != view {
			pendingViews.append(detachedView)
		}
		viewStore[state] = nil
	}

	// MARK: Subscripting

	public subscript(state: StatefulViewControllerState) -> UIView? {
		get {
			return viewForState(state)
		}
		set(newValue) {
			if let value = newValue {
				addView(value, forState: state)
			} else {
				removeViewForState(state)
			}
		}
	}

	// MARK: Switch view state

	/// Adds and removes views to and from the `view` based on the given state.
	/// Animations are synchronized in order to make sure that there aren't any animation gliches in the UI
	///
	/// - parameter state:		The state to transition to
	/// - parameter animated:	true if the transition should fade views in and out
	/// - parameter completion:	called when all animations are finished and the view has been updated
	///
	public func transitionToState(_ state: ViewStateMachineState, animated: Bool = true, completion: (() -> Void)? = nil) {
		lastState = state

		queue.addOperation(AsyncOperation { [weak self] finish in
			guard let self = self,
				state != self.currentState else { return finish() }

			self.currentState = state

			let handler: () -> Void = {
				finish()
				completion?()
			}

			// Switch state and update the view
			DispatchQueue.main.sync {
				self.removePendingViews()
				switch state {
				case .none:
					self.hideAllViews(animated: animated, completion: handler)
				case .view(let viewKey):
					self.showView(forKey: viewKey, animated: animated, completion: handler)
				}
			}
		})
	}

	// MARK: Private view updates

	private func showView(forKey state: StatefulViewControllerState, animated: Bool, completion: (() -> Void)? = nil) {
		guard let view = view else { return }

		// Add the container view
		containerView.frame = view.bounds
		view.addSubview(containerView)

		let store = viewStore

		if let newView = store[state] {
			newView.alpha = animated ? 0.0 : 1.0

			// Add new view using AutoLayout
			newView.translatesAutoresizingMaskIntoConstraints = false
			containerView.addSubview(newView)

			var placeholderView = newView as? StatefulPlaceholderView
			let insets = placeholderView?.placeholderViewInsets() ?? .zero

			addConstraints(for: newView, insets: insets)
			placeholderView?.configure { [weak self] in
				self?.updateConstraints()
			}
		}

		let animations: () -> Void = {
			if let newView = store[state] {
				newView.alpha = 1.0
			}
		}

		let animationCompletion: (Bool) -> Void = { _ in
			for (key, view) in store where key != state {
				view.removeFromSuperview()
			}

			completion?()
		}

		animateChanges(animated: animated, animations: animations, completion: animationCompletion)
	}

	private func hideAllViews(animated: Bool, completion: (() -> Void)? = nil) {
		let store = viewStore

		let animations: () -> Void = {
			for (_, view) in store {
				view.alpha = 0.0
			}
		}

		let animationCompletion: (Bool) -> Void = { [weak self] _ in
			for (_, view) in store {
				view.removeFromSuperview()

				if let placeholderView = view as? StatefulPlaceholderView {
					placeholderView.configure(updateHandler: nil)
				}
			}

			// Remove the container view
			self?.containerView.removeFromSuperview()
			completion?()
		}

		animateChanges(animated: animated, animations: animations, completion: animationCompletion)
	}

	/// Removes all views marked as pending from the view hierachy.
	private func removePendingViews() {
		for view in pendingViews {
			view.removeFromSuperview()

			if let placeholderView = view as? StatefulPlaceholderView {
				placeholderView.configure(updateHandler: nil)
			}
		}
		pendingViews.removeAll()
	}

	private func animateChanges(animated: Bool, animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
		if animated {
			UIView.animate(withDuration: 0.3, animations: animations, completion: completion)
		} else {
			completion?(true)
		}
	}
}

// MARK: - Constraints

private extension ViewStateMachine {
	enum ConstraintIdentifier: String {
		case top, bottom, left, right
	}

	func addConstraints(for view: UIView, insets: UIEdgeInsets) {
		if #available(iOS 11.0, *), false {
			addConstraints(for: view, insets: insets, layoutGuide: containerView.safeAreaLayoutGuide)
		} else {
			addConstraintsOld(for: view, insets: insets)
		}
	}

	func addConstraintsOld(for view: UIView, insets: UIEdgeInsets) {
		let metrics = ["top": insets.top, "bottom": insets.bottom, "left": insets.left, "right": insets.right]
		let views = ["view": view]

		let leftConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-left-[view]", options: [], metrics: metrics, views: views)
		leftConstraints.forEach { $0.identifier = ConstraintIdentifier.left.rawValue }

		let rightConstraints = NSLayoutConstraint.constraints(withVisualFormat: "[view]-right-|", options: [], metrics: metrics, views: views)
		rightConstraints.forEach { $0.identifier = ConstraintIdentifier.right.rawValue }

		let topConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-top-[view]", options: [], metrics: metrics, views: views)
		topConstraints.forEach { $0.identifier = ConstraintIdentifier.top.rawValue }

		let bottomConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[view]-bottom-|", options: [], metrics: metrics, views: views)
		bottomConstraints.forEach { $0.identifier = ConstraintIdentifier.bottom.rawValue }

		containerView.addConstraints(leftConstraints)
		containerView.addConstraints(rightConstraints)
		containerView.addConstraints(topConstraints)
		containerView.addConstraints(bottomConstraints)
	}

	@available(iOS 11.0, *)
	func addConstraints(for view: UIView, insets: UIEdgeInsets, layoutGuide: UILayoutGuide) {
		let leftConstraint = view.leftAnchor.constraint(equalTo: layoutGuide.leftAnchor, constant: insets.left)
		leftConstraint.identifier = ConstraintIdentifier.left.rawValue

		let rightConstraint = layoutGuide.rightAnchor.constraint(equalTo: view.rightAnchor, constant: insets.right)
		rightConstraint.identifier = ConstraintIdentifier.right.rawValue

		let topConstraint = view.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: insets.top)
		topConstraint.identifier = ConstraintIdentifier.top.rawValue

		let bottomConstraint = layoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom)
		bottomConstraint.identifier = ConstraintIdentifier.bottom.rawValue

		NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
	}

	func updateConstraints() {
		switch currentState {
		case .view(let state):
			if let view = viewStore[state] as? StatefulPlaceholderView {
				updateConstraints(for: containerView, insets: view.placeholderViewInsets())
			}
		default:
			break
		}
	}

	func updateConstraints(for view: UIView, insets: UIEdgeInsets) {
		let constraints = Dictionary(grouping: view.constraints) { $0.identifier.flatMap { ConstraintIdentifier(rawValue: $0) } }
		constraints[.top]?.forEach { $0.constant = insets.top }
		constraints[.bottom]?.forEach { $0.constant = insets.bottom }
		constraints[.left]?.forEach { $0.constant = insets.left }
		constraints[.right]?.forEach { $0.constant = insets.right }
	}
}
