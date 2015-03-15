//  Copyright (c) 2015 Neil Pankey. All rights reserved.

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
        // TODO This should return the tail of the list as well so we don't rely on `last`
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

    /// Inserts a new `value` before the `first` value
    public mutating func prepend(value: T) {
        head = head?.insertBefore(value)
        if head == nil {
            head = Node(value)
            tail = head
        }
    }

    /// Inserts a new `value` after the `last` value
    public mutating func append(value: T) {
        tail = tail?.insertAfter(value)
        if tail == nil {
            tail = Node(value)
            head = tail
        }
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

    /// The type of nodes in `List`.
    private typealias Node = ListNode<T>

    /// The first node of `List`.
    private var head: Node?

    /// The last node of `List`.
    private var tail: Node?
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

// MARK: CollectionType

extension List : CollectionType {
    public typealias Index = ListIndex<T>

    /// Index to the first element of `List`.
    public var startIndex: Index {
        return Index(head)
    }

    /// Index past the last element of `List`.
    public var endIndex: Index {
        return Index(nil)
    }

    /// Returns the element in `List` at `index`.
    public subscript(index: Index) -> T {
        return index.node!.value
    }
}

// MARK: Sliceable

extension List : Sliceable {
    public typealias SubSlice = List

    /// Extract a slice of `List` from bounds.
    public subscript (bounds: Range<Index>) -> SubSlice {
        // TODO Defer cloning the nodes until modification
        var head = bounds.startIndex.node
        var tail = bounds.endIndex.node
        return head == tail ? List() : List(head?.clone(tail))
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

    /// Create an index pointing to `node`.
    private init(_ node: Node?) {
        self.node = node
    }

    /// Returns the next `ListIndex`.
    public func successor() -> ListIndex {
        return ListIndex(node!.next)
    }
}

/// Determines if two indexes are equal.
public func == <T> (lhs: ListIndex<T>, rhs: ListIndex<T>) -> Bool {
    return lhs.node == rhs.node
}
