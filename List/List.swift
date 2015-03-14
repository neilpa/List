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
