//  Copyright (c) 2015 Neil Pankey. All rights reserved.

/// The nodes of a `BidirectionalList`.
internal final class BidirectionalListNode<T> : NodeType {
    // MARK: Constructors

    /// Initialize a new node with `value` and no `previous` or `next`.
    internal convenience init(_ value: T) {
        self.init(nil, value, nil)
    }

    // MARK: Properties

    /// The `value` at the this node.
    internal var value: T

    /// The head of the list.
    internal var previous: BidirectionalListNode?

    /// The remainder of the list.
    internal var next: BidirectionalListNode?

    /// MARK: Operations

    /// Replaces `next` of the receiver with a new value returning the created `ForwardListNode` which points at the replaced `next`.
    internal func insertAfter(value: T) -> BidirectionalListNode {
        return BidirectionalListNode(self, value, next)
    }

    // MARK: Private

    /// Initializes a new node with `previous`, `value` and `next`. The `previous` and `next` nodes are updated to point to `self`.
    private init(_ previous: BidirectionalListNode?, _ value: T, _ next: BidirectionalListNode?) {
        self.previous = previous
        self.value = value
        self.next = next

        previous?.next = self
        next?.previous = self
    }

}


