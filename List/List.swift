//  Copyright (c) 2015 Neil Pankey. All rights reserved.

/// Singly-linked list of values
public struct List<T> {
    // MARK: Constructors

    /// Initializes an empty `List`
    public init() {
    }

    // MARK: Private

    /// The type of nodes in `List`
    private typealias Node = ListNode<T>

    /// The `head` of `List`
    private var head: Node?
}
