//
// StatefulUI
// Copyright © 2024 Wisemen
//

import UIKit

/// Represents all possible states of a stateful view controller
public enum StatefulViewControllerState {
	case content
	case loading
	case error
	case empty
}

/// StatefulViewController protocol may be adopted by a view controller or a view in order to transition to
/// error, loading or empty views.
public protocol StatefulViewController: AnyObject, BackingViewProvider {
	/// The view state machine backing all state transitions
	var stateMachine: ViewStateMachine { get }

	/// The current transition state of the view controller.
	/// All states other than `Content` imply that there is a placeholder view shown.
	var currentState: StatefulViewControllerState { get }

	/// The last transition state that was sent to the state machine for execution.
	/// This does not imply that the state is currently shown on screen. Transitions are queued up and
	/// executed in sequential order.
	var lastState: StatefulViewControllerState { get }

	// MARK: Views

	/// Loads all the placeholder views the first time the state machine is accessed
	func initializeEmptyStateViews()

	/// The loading view is shown when the `startLoading` method gets called
	var loadingView: UIView? { get set }

	/// The error view is shown when the `endLoading` method returns an error
	var errorView: UIView? { get set }

	/// The empty view is shown when the `hasContent` method returns false
	var emptyView: UIView? { get set }

	/// Optional extra loading activity indicator if there is content
	var subtleActivityIndicatorView: ActivityIndicatingView? { get }

	// MARK: Transitions

	/// Sets up the initial state of the view.
	/// This method should be called as soon as possible in a view or view controller's
	/// life cycle, e.g. `viewWillAppear:`, to transition to the appropriate state.
	func setupInitialViewState(_ completion: (() -> Void)?)

	/// Transitions the controller to the loading state and shows
	/// the loading view if there is no content shown already.
	///
	/// - parameter animated: 	true if the switch to the placeholder view should be animated, false otherwise
	func startLoading(animated: Bool, completion: (() -> Void)?)

	/// Ends the controller's loading state.
	/// If an error occurred, the error view is shown.
	/// If the `hasContent` method returns false after calling this method, the empty view is shown.
	///
	/// - parameter animated: 	true if the switch to the placeholder view should be animated, false otherwise
	/// - parameter error:		An error that might have occurred whilst loading
	func endLoading(animated: Bool, error: Error?, completion: (() -> Void)?)

	/// Transitions the view to the appropriate state based on the `loading` and `error`
	/// input parameters and shows/hides corresponding placeholder views.
	///
	/// - parameter loading:		true if the controller is currently loading
	/// - parameter error:		An error that might have occurred whilst loading
	/// - parameter animated:	true if the switch to the placeholder view should be animated, false otherwise
	func transitionViewStates(loading: Bool, error: Error?, animated: Bool, completion: (() -> Void)?)

	// MARK: Content and error handling

	/// The view where content is shown in (for example the table view of a table view controller)
	var contentView: UIView { get }

	/// Return true if content is available in your controller.
	///
	/// - returns: true if there is content available in your controller.
	func hasContent() -> Bool

	/// This method is called if an error occurred, but `hasContent` returned true.
	/// You would typically display an unobstrusive error message that is easily dismissable
	/// for the user to continue browsing content.
	///
	/// - parameter error:	The error that occurred
	func handleErrorWhenContentAvailable(_ error: Error)
}
