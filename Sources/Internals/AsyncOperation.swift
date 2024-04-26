//
// StatefulUI
// Copyright © 2024 Wisemen
//

import Foundation

final class AsyncOperation: Operation {
	@objc private enum State: Int {
		case ready
		case executing
		case finished
	}

	private var _state: State = .ready
	private let stateQueue = DispatchQueue(label: "be.appwise.viewStateMachine.op.state", attributes: .concurrent)
	private let closure: ((@escaping () -> Void) -> Void)

	init(closure: @escaping ((@escaping () -> Void) -> Void)) {
		self.closure = closure
	}
}

// MARK: - Operation State

extension AsyncOperation {
	@objc private dynamic var state: State {
		get { return stateQueue.sync { _state } }
		set { stateQueue.sync(flags: .barrier) { _state = newValue } }
	}

	override var isAsynchronous: Bool {
		return true
	}

	override var isReady: Bool {
		return super.isReady && state == .ready
	}

	override var isExecuting: Bool {
		return state == .executing
	}

	override var isFinished: Bool {
		return state == .finished
	}

	override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
		if [#keyPath(isReady), #keyPath(isFinished), #keyPath(isExecuting)].contains(key) {
			return [#keyPath(state)]
		} else {
			return super.keyPathsForValuesAffectingValue(forKey: key)
		}
	}
}

// MARK: - Execution

extension AsyncOperation {
	override func start() {
		if isCancelled {
			finish()
		} else {
			state = .executing
			main()
		}
	}

	override func main() {
		closure {
			self.finish()
		}
	}

	private func finish() {
		if isExecuting {
			state = .finished
		}
	}
}
