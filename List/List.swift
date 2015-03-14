//  Copyright (c) 2015 Neil Pankey. All rights reserved.

/// Singly-linked list of values
public struct List<T> {
    // MARK: Constructors

    /// Initializes an empty `List`
    public init() {
    }

    // MARK: Properties

    /// Returns true iff `List` is empty
    public var isEmpty: Bool {
        return head == nil
    }

    /// Returns the `first` value in `List`, `nil` if empty.
    public var first: T? {
        return head?.value
    }

    // MARK: Private

    /// The type of nodes in `List`
    private typealias Node = ListNode<T>

    /// The `head` of `List`
    private var head: Node?
}

// MARK: SequenceType

extension List : SequenceType {
    public typealias Generator = GeneratorOf<T>

    /// Create a `Generator` that enumerates all the values in `List`
    public func generate() -> Generator {
        return head?.values() ?? Generator { nil }
    }
}

// MARK: CollectionType

extension List : CollectionType {
    public typealias Index = ListIndex<T>

    public var startIndex: Index {
        return Index(head)
    }

    public var endIndex: Index {
        return Index(nil)
    }

    public subscript(index: Index) -> T {
        return head!.value
    }
}

// MARK: ListIndex

/// Index for a `List`
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
