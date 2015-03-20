//  Copyright (c) 2015 Neil Pankey. All rights reserved.

/// Generic, singly-linked list of nodes. The basis for `List` and other higher level collections.
internal final class ListNode<T> {
    // MARK: Constructors

    /// Initialize a new node with `value` and no tail.
    internal convenience init(_ value: T) {
        self.init(value, nil)
    }

    /// Creates a new node list with `values`, or `nil` if empty.
    ///
    /// Ideally this would be a failable initializier but limitations in Swift prevent that
    /// prevent that on class types - http://stackoverflow.com/a/26497229/1999152.
    internal static func create<S: SequenceType where S.Generator.Element == T>(values: S) -> ListEnds<T> {
        var ends = ListEnds<T>()
        Swift.map(values) { ends.append($0) }
        return ends
    }

    // MARK: Properties

    /// The `value` at the this node.
    internal var value: T

    /// The remainder of the list.
    internal var next: ListNode?

    /// The `last` node in the list. This is O(n) since it walks the entire list.
    internal var last: ListNode {
        return next?.last ?? self
    }

    /// MARK: Operations

    /// Prefixes the receiver with a new value returning the created `ListNode`.
    internal func insertBefore(value: T) -> ListNode {
        return ListNode(value, self)
    }

    /// Replaces `next` of the receiver with a new value returning the created `ListNode` which points at the replaced `next`.
    internal func insertAfter(value: T) -> ListNode {
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
    internal typealias Generator = GeneratorOf<ListNode>

    /// Create a `Generator` that enumerates all the nodes.
    internal func generate() -> Generator {
        var node: ListNode? = self

        return Generator {
            let current = node
            node = current?.next
            return current
        }
    }

    /// Create a `Generator` that enumerates all the values of nodes.
    internal func values() -> GeneratorOf<T> {
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

// MARK: Higher-order functions

extension ListNode {
    /// Maps values in self with `transform` to create a new list.
    internal func map<U>(transform: T -> U) -> ListEnds<U> {
        return reduce(ListEnds<U>()) { (var ends, node) in
            ends.append(transform(node.value))
            return ends
        }
    }

    /// Filters values in self with `predicate` to create a new list.
    internal func filter(predicate: T -> Bool) -> ListEnds<T> {
        return self.reduce(ListEnds<T>()) { (var ends, node) in
            if predicate(node.value) {
                ends.append(node.value)
            }
            return ends
        }
    }

    /// Takes values up to `tail` to create a new list.
    internal func takeUntil(tail: ListNode?) -> ListEnds<T> {
        return takeWhile(ListEnds<T>()) { $0 != tail }
    }

    /// Takes values while `predicate` returns true to create a new list.
    internal func takeWhile(predicate: ListNode -> Bool) -> ListEnds<T> {
        return takeWhile(ListEnds<T>(), predicate)
    }

    /// Takes values while `predicate` returns true to create a new list.
    private func takeWhile(var ends: ListEnds<T>, _ predicate: ListNode -> Bool) -> ListEnds<T> {
        if !predicate(self) {
            return ends
        }

        ends.append(value)
        return next?.takeWhile(ends, predicate) ?? ends
    }

    /// Reduces all nodes to with `transform`.
    internal func reduce<U>(initial: U, _ transform: (U, ListNode) -> U) -> U {
        // TODO Would be nice if this were lazy
        let reduction = transform(initial, self)
        return next?.reduce(reduction, transform) ?? reduction
    }
}

// MARK: Equality

extension ListNode : Equatable {
}

/// Determines if two nodes are equal via identity.
internal func == <T> (lhs: ListNode<T>, rhs: ListNode<T>) -> Bool {
    return lhs === rhs
}

// MARK: ListEnds

/// Wrapper for the `head` and `tail` of list nodes. Generally used as an accumulator when mapping, filter, etc.
internal struct ListEnds<T> {
    internal var head: ListNode<T>?
    internal var tail: ListNode<T>?

    /// Appends a new `value` to the current `tail` and updates it.
    internal mutating func append(value: T) {
        if let node = tail?.insertAfter(value) {
            tail = node
        } else {
            head = ListNode<T>(value)
            tail = head
        }
    }
}
