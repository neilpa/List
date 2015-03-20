//  Copyright (c) 2015 Neil Pankey. All rights reserved.

import Dumpster

/// A singly-linked list of values.
public struct ForwardList<T> {
    // MARK: Constructors

    /// Initializes an empty `ForwardList`.
    public init() {
    }

    /// Initializes a `ForwardList` with a single `value`.
    public init(value: T) {
        self.init(Node(value))
    }

    /// Initializes a `ForwardList` with a collection of `values`.
    public init<S: SequenceType where S.Generator.Element == T>(_ values: S) {
        // TODO This should return the tail of the list as well so we don't rely on `head.last`
        self.init(Node.create(values))
    }

    /// Initializes `ForwardList` with `head`.
    private init(_ head: Node?) {
        self.init(head, head?.last)
    }

    /// Initializes `ForwardList` with a new set of `ends`
    private init(_ ends: ListEnds<Node>?) {
        self.init(ends?.head, ends?.tail)
    }

    /// Initializes `ForwardList` with `head` and `tail`.
    private init(_ head: Node?, _ tail: Node?) {
        self.head = head
        self.tail = tail
    }

    // MARK: Primitive operations

    /// Replace nodes at the given insertion point
    private mutating func spliceList(prefixTail: Node?, _ replacementHead: Node?, _ replacementTail: Node?, _ suffixHead: Node?) {
        if prefixTail == nil {
            head = replacementHead ?? suffixHead
        } else {
            prefixTail?.next = replacementHead ?? suffixHead
        }

        if suffixHead == nil {
            tail = replacementTail
        } else {
            replacementTail?.next = suffixHead
        }
    }

    /// Replace the nodes at `subRange` with the given replacements.
    private mutating func spliceList(subRange: Range<Index>, _ replacementHead: Node?, _ replacementTail: Node?) {
        spliceList(subRange.startIndex.previous, replacementHead, replacementTail, subRange.endIndex.node)
    }

    /// Inserts a new `node` between `prefix` and `suffix`.
    private mutating func insertNode(prefix: Node?, _ node: Node, _ suffix: Node?) {
        spliceList(prefix, node, node, suffix)
    }

    /// Removes the `node` that follows `previous`.
    private mutating func removeNode(node: Node, previous: Node?) -> T {
        precondition(previous?.next == node || previous == nil)

        let value = node.value
        spliceList(previous, nil, nil, node.next)
        return value
    }

    /// The type of nodes in `ForwardList`.
    private typealias Node = ForwardListNode<T>

    /// The first node of `ForwardList`.
    private var head: Node?

    /// The last node of `ForwardList`.
    private var tail: Node?
}

// MARK: Queue/Stack

extension ForwardList : QueueType, StackType {
    public typealias Element = T

    /// Returns true iff `ForwardList` is empty.
    public var isEmpty: Bool {
        return head == nil
    }

    /// Returns the value at the head of `ForwardList`, `nil` if empty.
    public var first: T? {
        return head?.value
    }

    /// Returns the value at the tail of `ForwardList`, `nil` if empty.
    public var last: T? {
        return tail?.value
    }
    
    /// Removes the `first` value at the head of `ForwardList` and returns it, `nil` if empty.
    public mutating func removeFirst() -> T {
        return removeNode(head!, previous: nil)
    }

    /// Inserts a new `value` _before_ the `first` value.
    public mutating func insertFirst(value: T) {
        insertNode(nil, Node(value), head)
    }

    /// Inserts a new `value` _after_ the `last` value.
    public mutating func insertLast(value: T) {
        insertNode(tail, Node(value), nil)
    }
}

// MARK: ArrayLiteralConvertible

extension ForwardList : ArrayLiteralConvertible {
    /// Initializes a `ForwardList` with the `elements` from array.
    public init(arrayLiteral elements: T...) {
        self.init(elements)
    }
}

// MARK: SequenceType

extension ForwardList : SequenceType {
    public typealias Generator = GeneratorOf<T>

    /// Create a `Generator` that enumerates all the values in `ForwardList`.
    public func generate() -> Generator {
        return head?.values() ?? Generator { nil }
    }
}

// MARK: CollectionType, MutableCollectionType

extension ForwardList : CollectionType, MutableCollectionType {
    public typealias Index = ForwardListIndex<T>

    /// Index to the first element of `ForwardList`.
    public var startIndex: Index {
        return Index(head)
    }

    /// Index past the last element of `ForwardList`.
    public var endIndex: Index {
        return Index(nil, tail)
    }

    /// Retrieves or updates the element in `ForwardList` at `index`.
    public subscript(index: Index) -> T {
        get {
            return index.node!.value
        }
        set {
            index.node!.value = newValue
        }
    }
}

// MARK: Sliceable, MutableSliceable

extension ForwardList : Sliceable, MutableSliceable {
    public typealias SubSlice = ForwardList

    /// Extract a slice of `ForwardList` from bounds.
    public subscript (bounds: Range<Index>) -> SubSlice {
        get {
            // TODO Defer cloning the nodes until modification
            var head = bounds.startIndex.node
            var tail = bounds.endIndex.node
            return head == tail ? ForwardList() : ForwardList(head?.takeUntil(tail))
        }
        set(newList) {
            spliceList(bounds, newList.head, newList.tail)
        }
    }
}

// MARK: ExtensibleCollectionType

extension ForwardList : ExtensibleCollectionType {
    /// Does nothing.
    public mutating func reserveCapacity(amount: Index.Distance) {
    }

    /// Appends `value to the end of `ForwardList`.
    public mutating func append(value: T) {
        self.insertLast(value)
    }

    /// Appends multiple elements to the end of `ForwardList`.
    public mutating func extend<S: SequenceType where S.Generator.Element == T>(values: S) {
        Swift.map(values) { self.insertLast($0) }
    }
}

// MARK: RangeReplaceableCollectionType

extension ForwardList : RangeReplaceableCollectionType {
    /// Replace the given `subRange` of elements with `values`.
    public mutating func replaceRange<C : CollectionType where C.Generator.Element == T>(subRange: Range<Index>, with values: C) {
        var replacement = Node.create(values)
        spliceList(subRange, replacement.head, replacement.tail)
    }

    /// Insert `value` at `index`.
    public mutating func insert(value: T, atIndex index: Index) {
        insertNode(index.previous, Node(value), index.node)
    }

    /// Insert `values` at `index`.
    public mutating func splice<C : CollectionType where C.Generator.Element == T>(values: C, atIndex index: Index) {
        var replacement = Node.create(values)
        spliceList(index.previous, replacement.head, replacement.tail, index.node)
    }

    /// Remove the element at `index` and returns it.
    public mutating func removeAtIndex(index: Index) -> T {
        return removeNode(index.node!, previous: index.previous)
    }

    /// Remove the indicated `subRange` of values.
    public mutating func removeRange(subRange: Range<Index>) {
        spliceList(subRange.startIndex.previous, nil, nil, subRange.endIndex.node)
    }

    /// Remove all values from `ForwardList`.
    public mutating func removeAll(#keepCapacity: Bool) {
        spliceList(nil, nil, nil, nil)
    }
}

// MARK: Printable

extension ForwardList : Printable, DebugPrintable {
    /// String representation of `ForwardList`.
    public var description: String {
        return describe(toString)
    }

    /// Debug string representation of `ForwardList`.
    public var debugDescription: String {
        return describe(toDebugString)
    }

    /// Formats elements of list for printing.
    public func describe(stringify: T -> String) -> String {
        let string = join(", ", lazy(self).map(stringify))
        return "[\(string)]"
    }
}

// MARK: Higher-order functions

extension ForwardList {
    /// Maps values in `ForwardList` with `transform` to create a new `ForwardList`
    public func map<U>(transform: T -> U) -> ForwardList<U> {
        return ForwardList<U>(head?.map(transform))
    }

    /// Filters values from `ForwardList` with `predicate` to create a new `ForwardList`
    public func filter(predicate: T -> Bool) -> ForwardList {
        return ForwardList(head?.filter(predicate))
    }
}
