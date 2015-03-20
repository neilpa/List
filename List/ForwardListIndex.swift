//  Copyright (c) 2015 Neil Pankey. All rights reserved.

/// Index to a value in `ForwardList`.
public struct ForwardListIndex<T> : ForwardIndexType {
    /// Nodes that the `ForwardListIndex` wraps.
    internal typealias Node = ForwardListNode<T>

    /// Current `node` that `ForwardListIndex` points at.
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

    /// Returns the next `ForwardListIndex`.
    public func successor() -> ForwardListIndex {
        return ForwardListIndex(node!.next, node)
    }
}

/// Determines if two indexes are equal.
public func == <T> (lhs: ForwardListIndex<T>, rhs: ForwardListIndex<T>) -> Bool {
    return lhs.node == rhs.node
}
