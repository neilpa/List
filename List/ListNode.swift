//  Copyright (c) 2015 Neil Pankey. All rights reserved.

/// Generic, singly-linked list of nodes. The basis for `List` and other higher level collections.
public final class ListNode<T> {
    // MARK: Constructors

    /// Initialize a new node with `value` and no tail.
    public convenience init(_ value: T) {
        self.init(value, nil)
    }

    // MARK: Properties

    /// The `value` at the this node.
    public let value: T

    /// The remainder of the list.
    public var next: ListNode?

    /// MARK: Operations

    /// Prefixes the receiver with a new value returning the created `ListNode`.
    public func insertBefore(value: T) -> ListNode {
        return ListNode(value, self)
    }

    /// Replaces `next` of the receiver with a new value returning the created `ListNode` which points at the replaced `next`.
    public func insertAfter() -> ListNode {
        next = ListNode(value, next)
        return next!
    }

    // MARK: Private

    /// Initializes a new node with `value` and `next`
    private init(_ value: T, _ next: ListNode?) {
        self.value = value
        self.next = next
    }

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
