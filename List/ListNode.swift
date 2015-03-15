//  Copyright (c) 2015 Neil Pankey. All rights reserved.

/// Generic, singly-linked list of nodes. The basis for `List` and other higher level collections.
public final class ListNode<T> {
    // MARK: Constructors

    /// Initialize a new node with `value` and no tail.
    public convenience init(_ value: T) {
        self.init(value, nil)
    }

    /// Creates a new node list with `values`, or `nil` if empty.
    ///
    /// Ideally this would be a failable initializier but limitations in Swift prevent that
    /// prevent that on class types - http://stackoverflow.com/a/26497229/1999152.
    public static func create<S: SequenceType where S.Generator.Element == T>(values: S) -> ListNode? {
        var generator = values.generate()
        if let first = generator.next() {
            return ListNode(first, generator)
        }
        return nil
    }

    // MARK: Properties

    /// The `value` at the this node.
    public let value: T

    /// The remainder of the list.
    public var next: ListNode?

    /// The `last` node in the list. This is O(n) since it walks the entire list.
    public var last: ListNode {
        return next?.last ?? self
    }

    /// MARK: Operations

    /// Prefixes the receiver with a new value returning the created `ListNode`.
    public func insertBefore(value: T) -> ListNode {
        return ListNode(value, self)
    }

    /// Replaces `next` of the receiver with a new value returning the created `ListNode` which points at the replaced `next`.
    public func insertAfter(value: T) -> ListNode {
        next = ListNode(value, next)
        return next!
    }

    // MARK: Private

    /// Initializes a new node with `value` and `next`.
    private init(_ value: T, _ next: ListNode?) {
        self.value = value
        self.next = next
    }

    /// Initializes a node list with `value` and consumes `generator` to append elements.
    private init<G: GeneratorType where G.Element == T>(_ value: T, var _ generator: G) {
        self.value = value
        if let tail = generator.next() {
            next = ListNode(tail, generator)
        }
    }
}

// MARK: SequenceType

extension ListNode : SequenceType {
    public typealias Generator = GeneratorOf<ListNode>

    /// Create a `Generator` that enumerates all the nodes.
    public func generate() -> Generator {
        var node: ListNode? = self

        return Generator {
            let current = node
            node = current?.next
            return current
        }
    }

    /// Create a `Generator` that enumerates all the values of nodes.
    public func values() -> GeneratorOf<T> {
        var node: ListNode? = self

        return GeneratorOf<T> {
            if let value = node?.value {
                node = node?.next
                return value
            }
            return nil
        }
    }
}

// MARK: Copying

extension ListNode {
    /// Recursively creates a copy of `ListNode`s until `tail` returning the new head.
    public func clone(tail: ListNode?) -> ListNode {
        return ListNode(value, next != tail ? next?.clone(tail) : nil)
    }
}

/// Recursively creates a copy of `ListNode`s returning the new head and tail.
public func clone<T>(node: ListNode<T>) -> (ListNode<T>, ListNode<T>) {
    let head = ListNode(node.value)
    return clone(head, head, node)
}

/// Recursively creates a copy of `ListNode`s returning the new head and tail.
private func clone<T>(head: ListNode<T>, tail: ListNode<T>, original: ListNode<T>) -> (ListNode<T>, ListNode<T>) {
    if let next = original.next {
        tail.next = ListNode(next.value)
        return clone(head, tail.next!, next)
    }
    return (head, tail)
}

// MARK: Equality

extension ListNode : Equatable {
}

/// Determines if two nodes are equal via identity.
public func == <T> (lhs: ListNode<T>, rhs: ListNode<T>) -> Bool {
    return lhs === rhs
}
