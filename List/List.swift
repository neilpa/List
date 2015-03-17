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

    // MARK: Properties

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

    /// MARK: Operations

    /// Inserts a new `value` before the `first` value.
    public mutating func prepend(value: T) {
        insert(value, atIndex: startIndex)
    }

    /// Inserts a new `value` after the `last` value.
    public mutating func append(value: T) {
        insert(value, atIndex: endIndex)
    }

    // MARK: Private

    /// Initializes `List` with `head`.
    private init(_ head: Node?) {
        self.init(head, head?.last)
    }

    /// Initializes `List` with `head` and `tail`
    private init(_ head: Node?, _ tail: Node?) {
        self.head = head
        self.tail = tail
    }

    /// Replace the nodes at `subRange` with the given replacements.
    private mutating func spliceList(subRange: Range<Index>, _ replacementHead: ListNode<T>?, _ replacementTail: ListNode<T>?) {
        var prefixTail = subRange.startIndex.previous
        var suffixHead = subRange.endIndex.node

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

    /// Removes the `first` value at the head of `List` and returns it, `nil` if empty.
    public mutating func popFirst() -> T? {
        let value = head?.value
        self.removeAtIndex(startIndex)
        return value
    }

    /// Inserts a new `value` before the `first` value.
    public mutating func pushFirst(value: T) {
        prepend(value)
    }

    /// Inserts a new `value` after the `last` value.
    public mutating func pushLast(value: T) {
        append(value)
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
            return head == tail ? List() : List(head?.clone(tail))
        }
        set(newList) {
            self.spliceList(bounds, newList.head, newList.tail)
        }
    }
}

// MARK: ExtensibleCollectionType

extension List : ExtensibleCollectionType {
    /// Does nothing.
    public mutating func reserveCapacity(amount: Index.Distance) {
    }

    /// Appends multiple elements to the end of `Queue`
    public mutating func extend<S: SequenceType where S.Generator.Element == T>(values: S) {
        map(values) { self.append($0) }
    }
}

// MARK: RangeReplaceableCollectionType

extension List : RangeReplaceableCollectionType {
    /// Replace the given `subRange` of elements with `newElements`.
    public mutating func replaceRange<C : CollectionType where C.Generator.Element == T>(subRange: Range<Index>, with newElements: C) {
        var replacement = Node.create(newElements)
        spliceList(subRange, replacement, replacement?.last)
    }

    // The remaining methods rely on the Swift stdlib equivalent which are implemented
    // in terms of `rangeReplace`

    /// Insert `newElement` at index `i`.
    public mutating func insert(newElement: T, atIndex i: Index) {
        Swift.insert(&self, newElement, atIndex: i)
    }

    /// Insert `newElements` at index `i`
    public mutating func splice<C : CollectionType where C.Generator.Element == T>(newElements: C, atIndex i: Index) {
        Swift.splice(&self, newElements, atIndex: i)
    }

    /// Remove the element at index `i`
    public mutating func removeAtIndex(i: Index) -> T {
        return Swift.removeAtIndex(&self, i)
    }

    /// Remove the indicated `subRange` of elements
    public mutating func removeRange(subRange: Range<Index>) {
        return Swift.removeRange(&self, subRange)
    }

    /// Remove all elements
    public mutating func removeAll(#keepCapacity: Bool) {
        return Swift.removeAll(&self, keepCapacity: keepCapacity)
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

// MARK: ListIndex

/// Index to a value in `List`.
public struct ListIndex<T> : ForwardIndexType {
    /// Nodes that the `ListIndex` wraps.
    private typealias Node = ListNode<T>

    /// Current `node` that `ListIndex` points at.
    private let node: Node?

    /// The node before `node`, enables RangeRepleaceableCollectionType
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
