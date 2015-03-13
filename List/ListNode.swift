//  Copyright (c) 2015 Neil Pankey. All rights reserved.

/// Generic, singly-linked list of nodes. This is the basis of `List` and can
/// be used for building for other higher level collections.
public final class ListNode<T> {
    // MARK: Constructors

    /// Initialize a new node with `value` and no tail
    public init(_ value: T) {
        self.value = value
    }

    // MARK: Properties

    /// The `value` at the this node
    public let value: T

    /// The remainder of the list
    public var next: ListNode?
}

// MARK: SequenceType

extension ListNode : SequenceType {
    typealias Generator = GeneratorOf<ListNode>

    /// Create a `Generator` that enumerates all the nodes
    public func generate() -> Generator {
        var node: ListNode? = self

        return Generator {
            let current = node
            node = current?.next
            return current
        }
    }
}
