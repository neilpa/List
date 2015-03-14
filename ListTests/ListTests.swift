//  Copyright (c) 2015 Neil Pankey. All rights reserved.

import List

import Assertions
import Equality
import XCTest

final class ListTests: XCTestCase {
    func testEmptyList() {
        assertEmpty(List<Bool>())
        assertEmpty(List<String>())
        assertEmpty(List<Int>())
    }

    func testSingleConstruction() {
        assert(List(value: 42), ==, [42])
        assert(List(value: false), ==, [false])
        assert(List(value: "hi"), ==, ["hi"])
    }

    func testPrepend() {
        var list: List<Int> = List()

        list.prepend(1)
        assert(list, ==, [1])

        list.prepend(2)
        list.prepend(3)
        assert(list, ==, [3, 2, 1])
    }

    func assertEmpty<T>(list: List<T>) {
        assertEqual(list.isEmpty, true)
        assertNil(list.first)
    }
}
