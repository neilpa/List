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

    func testArrayLiteralConvertible() {
        var list: List<Int> = []
        assertEmpty(list)

        list = [42]
        assert(list, ==, [42])

        list = [1, 2, 3]
        assert(list, ==, [1, 2, 3])
    }

    func testCollectionType() {
        let list: List<Character> = ["a", "b", "c", "d", "e"]
        var index = list.startIndex
        assertEqual(list[index++], "a")
        assertEqual(list[index++], "b")
        assertEqual(list[index++], "c")
        assertEqual(list[index++], "d")
        assertEqual(list[index++], "e")
        assertEqual(index, list.endIndex)
    }

    func testSliceable() {
        let list: List<Character> = ["a", "b", "c", "d", "e"]
        let fst = list.startIndex
        let snd = fst.successor()
        let thrd = snd.successor()
        let end = list.endIndex

        assert(list, ==, list[fst..<end])

        assertEmpty(list[fst..<fst])
        assertEmpty(list[thrd..<thrd])
        assertEmpty(list[end..<end])

        assert(["a"], ==, list[fst..<snd])
        assert(["a"], ==, list[fst...fst])

        assert(["b"], ==, list[snd..<thrd])
        assert(["b"], ==, list[snd...snd])

        assert(["a", "b",], ==, list[fst..<thrd])
        assert(["b", "c",], ==, list[fst.successor()..<thrd.successor()])

        assert(["c", "d", "e"], ==, list[thrd..<end])
        assert(["c", "d"], ==, list[thrd...thrd.successor()])
    }

    func assertEmpty<T>(list: List<T>, file: String = __FILE__, line: UInt = __LINE__) {
        assertEqual(list.isEmpty, true, "", file, line)
        assertNil(list.first, "", file: file, line: line)
    }
}
