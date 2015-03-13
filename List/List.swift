//  Copyright (c) 2015 Neil Pankey. All rights reserved.

/// Singly-linked list of values
internal final class List<T> {
    internal let value: T
    internal var next: List?

    internal init(_ value: T) {
        self.value = value
    }
}

extension List : SequenceType {
    typealias Generator = GeneratorOf<List>

    func generate() -> Generator {
        var node: List? = self

        return Generator {
            let current = node
            node = current?.next
            return current
        }
    }
}
