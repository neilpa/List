//  Copyright (c) 2015 Neil Pankey. All rights reserved.

import Dumpster

/// A singly-linked list of values.
public struct List<T> {
    // MARK: Constructors

    /// Initializes an empty `List`.
    public init() {
    }

    /// Initializes a `List` with a single `value`.
    public init(value: T) {
        self.init(Node(value))
    }

    /// Initializes a `List` with a collection of `values`.
    public init<S: SequenceType where S.Generator.Element == T>(_ values: S) {
        // TODO This should return the tail of the list as well so we don't rely on `head.last`
        self.init(Node.create(values))
    }

    /// Initializes `List` with `head`.
    private init(_ head: Node?) {
        self.init(head, head?.last)
    }

    /// Initializes `List` with a new set of `ends`
    private init(_ ends: ListEnds<Node>?) {
        self.init(ends?.head, ends?.tail)
    }

    /// Initializes `List` with `head` and `tail`.
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

    /// The type of nodes in `List`.
    private typealias Node = ListNode<T>

    /// The first node of `List`.
    private var head: Node?

    /// The last node of `List`.
    private var tail: Node?
}

// MARK: Queue/Stack

extension List : QueueType, StackType {
    public typealias Element = T

    /// Returns true iff `List` is empty.
    public var isEmpty: Bool {
        return head == nil
    }

    /// Returns the value at the head of `List`, `nil` if empty.
    public var first: T? {
        return head?.value
    }

    /// Returns the value at the tail of `List`, `nil` if empty.
    public var last: T? {
        return tail?.value
    }
    
    /// Removes the `first` value at the head of `List` and returns it, `nil` if empty.
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

extension List : ArrayLiteralConvertible {
    /// Initializes a `List` with the `elements` from array.
    public init(arrayLiteral elements: T...) {
        self.init(elements)
    }
}

// MARK: SequenceType

extension List : SequenceType {
    public typealias Generator = GeneratorOf<T>

    /// Create a `Generator` that enumerates all the values in `List`.
    public func generate() -> Generator {
        return head?.values() ?? Generator { nil }
    }
}

// MARK: CollectionType, MutableCollectionType

extension List : CollectionType, MutableCollectionType {
    public typealias Index = ListIndex<T>

    /// Index to the first element of `List`.
    public var startIndex: Index {
        return Index(head)
    }

    /// Index past the last element of `List`.
    public var endIndex: Index {
        return Index(nil, tail)
    }

    /// Retrieves or updates the element in `List` at `index`.
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

extension List : Sliceable, MutableSliceable {
    public typealias SubSlice = List

    /// Extract a slice of `List` from bounds.
    public subscript (bounds: Range<Index>) -> SubSlice {
        get {
            // TODO Defer cloning the nodes until modification
            var head = bounds.startIndex.node
            var tail = bounds.endIndex.node
            return head == tail ? List() : List(head?.takeUntil(tail))
        }
        set(newList) {
            spliceList(bounds, newList.head, newList.tail)
        }
    }
}

// MARK: ExtensibleCollectionType

extension List : ExtensibleCollectionType {
    /// Does nothing.
    public mutating func reserveCapacity(amount: Index.Distance) {
    }

    /// Appends `value to the end of `List`.
    public mutating func append(value: T) {
        self.insertLast(value)
    }

    /// Appends multiple elements to the end of `List`.
    public mutating func extend<S: SequenceType where S.Generator.Element == T>(values: S) {
        Swift.map(values) { self.insertLast($0) }
    }
}

// MARK: RangeReplaceableCollectionType

extension List : RangeReplaceableCollectionType {
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

    /// Remove all values from `List`.
    public mutating func removeAll(#keepCapacity: Bool) {
        spliceList(nil, nil, nil, nil)
    }
}

// MARK: Printable

extension List : Printable, DebugPrintable {
    /// String representation of `List`.
    public var description: String {
        return describe(toString)
    }

    /// Debug string representation of `List`.
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

extension List {
    /// Maps values in `List` with `transform` to create a new `List`
    public func map<U>(transform: T -> U) -> List<U> {
        return List<U>(head?.map(transform))
    }

    /// Filters values from `List` with `predicate` to create a new `List`
    public func filter(predicate: T -> Bool) -> List {
        return List(head?.filter(predicate))
    }
}

// MARK: ListIndex

/// Index to a value in `List`.
public struct ListIndex<T> : ForwardIndexType {
    /// Nodes that the `ListIndex` wraps.
    private typealias Node = ListNode<T>

    /// Current `node` that `ListIndex` points at.
    private let node: Node?

    /// The node before `node`, enables RangeRepleaceableCollectionType.
    private let previous: Node?

    /// Create an index pointing to `node`.
    private init(_ node: Node?) {
        self.init(node, nil)
    }

    /// Create an index pointing to `node` which follows `previous`.
    private init(_ node: Node?, _ previous: Node?) {
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
