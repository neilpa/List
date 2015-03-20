//  Copyright (c) 2015 Neil Pankey. All rights reserved.

/// Generic, singly-linked list of nodes. The basis for `ForwardList` and other higher level collections.
internal final class ForwardListNode<T> : NodeType {
    // MARK: Constructors

    /// Initialize a new node with `value` and no tail.
    internal convenience init(_ value: T) {
        self.init(value, nil)
    }

    /// Creates a new node list with `values`, or `nil` if empty.
    ///
    /// Ideally this would be a failable initializier but limitations in Swift prevent that
    /// prevent that on class types - http://stackoverflow.com/a/26497229/1999152.
    internal static func create<S: SequenceType where S.Generator.Element == T>(values: S) -> Ends {
        var ends = Ends()
        Swift.map(values) { ends.append($0) }
        return ends
    }

    // MARK: Properties

    /// The `value` at the this node.
    internal var value: T

    /// The remainder of the list.
    internal var next: ForwardListNode?

    /// The `last` node in the list. This is O(n) since it walks the entire list.
    internal var last: ForwardListNode {
        return next?.last ?? self
    }

    /// MARK: Operations

    /// Prefixes the receiver with a new value returning the created `ForwardListNode`.
    internal func insertBefore(value: T) -> ForwardListNode {
        return ForwardListNode(value, self)
    }

    /// Replaces `next` of the receiver with a new value returning the created `ForwardListNode` which points at the replaced `next`.
    internal func insertAfter(value: T) -> ForwardListNode {
        next = ForwardListNode(value, next)
        return next!
    }

    // MARK: Private
    private typealias Ends = ListEnds<ForwardListNode>

    /// Initializes a new node with `value` and `next`.
    private init(_ value: T, _ next: ForwardListNode?) {
        self.value = value
        self.next = next
    }

    /// Initializes a node list with `value` and consumes `generator` to append elements.
    private init<G: GeneratorType where G.Element == T>(_ value: T, var _ generator: G) {
        self.value = value
        if let tail = generator.next() {
            next = ForwardListNode(tail, generator)
        }
    }
}

// MARK: SequenceType

extension ForwardListNode : SequenceType {
    internal typealias Generator = GeneratorOf<ForwardListNode>

    /// Create a `Generator` that enumerates all the nodes.
    internal func generate() -> Generator {
        var node: ForwardListNode? = self

        return Generator {
            let current = node
            node = current?.next
            return current
        }
    }

    /// Create a `Generator` that enumerates all the values of nodes.
    internal func values() -> GeneratorOf<T> {
        var node: ForwardListNode? = self

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

extension ForwardListNode {
    /// Maps values in self with `transform` to create a new list.
    internal func map<U>(transform: T -> U) -> ListEnds<ForwardListNode<U>> {
        return reduce(ListEnds<ForwardListNode<U>>()) { (var ends, node) in
            ends.append(transform(node.value))
            return ends
        }
    }

    /// Filters values in self with `predicate` to create a new list.
    internal func filter(predicate: T -> Bool) -> Ends {
        return self.reduce(Ends()) { (var ends, node) in
            if predicate(node.value) {
                ends.append(node.value)
            }
            return ends
        }
    }

    /// Takes values up to `tail` to create a new list.
    internal func takeUntil(tail: ForwardListNode?) -> Ends {
        return takeWhile(Ends()) { $0 != tail }
    }

    /// Takes values while `predicate` returns true to create a new list.
    internal func takeWhile(predicate: ForwardListNode -> Bool) -> Ends {
        return takeWhile(Ends(), predicate)
    }

    /// Takes values while `predicate` returns true to create a new list.
    private func takeWhile(var ends: Ends, _ predicate: ForwardListNode -> Bool) -> Ends {
        if !predicate(self) {
            return ends
        }

        ends.append(value)
        return next?.takeWhile(ends, predicate) ?? ends
    }

    /// Reduces all nodes to with `transform`.
    internal func reduce<U>(initial: U, _ transform: (U, ForwardListNode) -> U) -> U {
        // TODO Would be nice if this were lazy
        let reduction = transform(initial, self)
        return next?.reduce(reduction, transform) ?? reduction
    }
}

// MARK: Equality

extension ForwardListNode : Equatable {
}

/// Determines if two nodes are equal via identity.
internal func == <T> (lhs: ForwardListNode<T>, rhs: ForwardListNode<T>) -> Bool {
    return lhs === rhs
}

