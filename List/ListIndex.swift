//  Copyright (c) 2015 Neil Pankey. All rights reserved.

/// Index to a value in `List`.
public struct ListIndex<T> : ForwardIndexType {
    /// Nodes that the `ListIndex` wraps.
    internal typealias Node = ListNode<T>

    /// Current `node` that `ListIndex` points at.
    internal let node: Node?

    /// The node before `node`, enables RangeRepleaceableCollectionType.
    internal let previous: Node?

    /// Create an index pointing to `node`.
    internal init(_ node: Node?) {
        self.init(node, nil)
    }

    /// Create an index pointing to `node` which follows `previous`.
    internal init(_ node: Node?, _ previous: Node?) {
        precondition(previous?.next == node || previous == nil)

        self.node = node
        self.previous = previous
    }

    /// Returns the next `ListIndex`.
    public func successor() -> ListIndex {
        return ListIndex(node!.next, node)
    }
}

/// Determines if two indexes are equal.
public func == <T> (lhs: ListIndex<T>, rhs: ListIndex<T>) -> Bool {
    return lhs.node == rhs.node
}
