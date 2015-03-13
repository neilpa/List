//  Copyright (c) 2015 Neil Pankey. All rights reserved.

/// Singly-linked list of values
public final class List<T> {
    public let value: T
    public var next: List?

    public init(_ value: T) {
        self.value = value
    }
}

extension List : SequenceType {
    typealias Generator = GeneratorOf<List>

    public func generate() -> Generator {
        var node: List? = self

        return Generator {
            let current = node
            node = current?.next
            return current
        }
    }
}
