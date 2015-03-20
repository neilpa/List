//  Copyright (c) 2015 Neil Pankey. All rights reserved.

/// Index to a value in `BidirectionalList`.
public struct BidirectionalListIndex<T> : BidirectionalIndexType {
    /// Node type that this index wraps.
    internal typealias Node = BidirectionalListNode<T>

    /// Current `node` that `BidirectionalListIndex` points at.
    internal let node: Node?

    /// Create an index pointing to `node`.
    internal init(_ node: Node?) {
        self.node = node
    }

    /// Returns the next `BidirectionalListIndex`.
    public func successor() -> BidirectionalListIndex {
        return BidirectionalListIndex(node!.next)
    }

    /// Returns the next `BidirectionalListIndex`.
    public func predecessor() -> BidirectionalListIndex {
        return BidirectionalListIndex(node!.previous)
    }
}

/// Determines if two indexes are equal.
public func == <T> (lhs: BidirectionalListIndex<T>, rhs: BidirectionalListIndex<T>) -> Bool {
    return lhs.node === rhs.node
}
