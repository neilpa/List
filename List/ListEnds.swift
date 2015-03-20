//  Copyright (c) 2015 Neil Pankey. All rights reserved.

/// Wrapper for the `head` and `tail` of list nodes. Generally used as an accumulator when mapping, filter, etc.
internal struct ListEnds<Node: NodeType> {
    /// The first node in a list.
    internal var head: Node?

    /// The last node in a list.
    internal var tail: Node?

    /// Appends a new `value` to the current `tail` and updates it.
    internal mutating func append(value: Node.Value) {
        if let node = tail?.insertAfter(value) {
            tail = node
        } else {
            head = Node(value)
            tail = head
        }
    }
}
