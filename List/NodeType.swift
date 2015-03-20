//  Copyright (c) 2015 Neil Pankey. All rights reserved.

/// Protocol for both singly and doubly linked list nodes.
internal protocol NodeType {
    /// Type of value stored in the list node.
    typealias Value

    /// Construct a new node from `value`.
    init(_ value: Value)

    /// The `value` stored at this node.
    var value: Value { get set }

    /// The remainder of the list nodes.
    var next: Self? { get set }

    /// Appends the receiver with a new value returning the created node. Next and/or previous nodes are updated as expected.
    mutating func insertAfter(value: Value) -> Self
}
