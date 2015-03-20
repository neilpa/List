//  Copyright (c) 2015 Neil Pankey. All rights reserved.

import List

import Assertions
import Equality
import XCTest

final class ForwardListTests: XCTestCase {
    func testEmptyList() {
        assertEmpty(ForwardList<Bool>())
        assertEmpty(ForwardList<String>())
        assertEmpty(ForwardList<Int>())
    }

    func testInsertFirst() {
        var list: ForwardList<Int> = ForwardList()

        list.insertFirst(1)
        assert(list, ==, [1])

        list.insertFirst(2)
        list.insertFirst(3)
        assert(list, ==, [3, 2, 1])
    }

    func testInsertLast() {
        var list: ForwardList<Int> = ForwardList()

        list.insertLast(1)
        assert(list, ==, [1])

        list.insertLast(2)
        list.insertLast(3)
        assert(list, ==, [1, 2, 3])
    }

    func testSingleConstruction() {
        assert(ForwardList(value: 42), ==, [42])
        assert(ForwardList(value: false), ==, [false])
        assert(ForwardList(value: "hi"), ==, ["hi"])

        var list = ForwardList(value: 1)
        list.insertLast(2)
        assert(list, ==, [1, 2])

        list.insertFirst(3)
        assert(list, ==, [3, 1, 2])
    }

    func testArrayLiteralConvertible() {
        var list: ForwardList<Int> = []
        assertEmpty(list)

        list = [42]
        assert(list, ==, [42])

        list = [1, 2, 3]
        assert(list, ==, [1, 2, 3])

        list.insertFirst(0)
        assert(list, ==, [0, 1, 2, 3])

        list.insertLast(4)
        assert(list, ==, [0, 1, 2, 3, 4])
    }

    func testCollectionType() {
        let list: ForwardList<Character> = ["a", "b", "c", "d", "e"]
        var index = list.startIndex
        assertEqual(list[index++], "a")
        assertEqual(list[index++], "b")
        assertEqual(list[index++], "c")
        assertEqual(list[index++], "d")
        assertEqual(list[index++], "e")
        assertEqual(index, list.endIndex)
    }

    func testMutableCollectionType() {
        var list: ForwardList<String> = ["a", "b", "c", "d", "e"]
        for index in list.startIndex..<list.endIndex {
            list[index] = list[index].uppercaseString
        }
        assert(list, ==, ["A", "B", "C", "D", "E"])
    }

    func testSliceable() {
        let list: ForwardList<Character> = ["a", "b", "c", "d", "e"]
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

    func testSliceMutations() {
        var list: ForwardList<Int> = [1, 2, 3, 4]
        let index = list.startIndex.successor()
        var slice = list[index...index.successor()]

        list.insertFirst(0)
        assert([2, 3], ==, slice)
        assert([0, 1, 2, 3, 4], ==, list)

        list.insertLast(5)
        assert([2, 3], ==, slice)
        assert([0, 1, 2, 3, 4, 5], ==, list)

        slice.insertLast(6)
        assert([2, 3, 6], ==, slice)
        assert([0, 1, 2, 3, 4, 5], ==, list)

        slice.insertFirst(-1)
        assert([-1, 2, 3, 6], ==, slice)
        assert([0, 1, 2, 3, 4, 5], ==, list)
    }

    func testMutableSlice() {
        var list: ForwardList<Int> = [1, 2, 3, 4]

        list[list.startIndex...list.startIndex] = ForwardList<Int>([9, 8])
        assert(list, ==, [9, 8, 2, 3, 4])

        list[list.endIndex..<list.endIndex] = ForwardList<Int>(value: 5)
        assert(list, ==, [9, 8, 2, 3, 4, 5])

        list[list.startIndex.successor()..<advance(list.startIndex, 3)] = ForwardList<Int>([6, 6, 6])
        assert(list, ==, [9, 6, 6, 6, 3, 4, 5])

        list[list.startIndex..<list.endIndex] = ForwardList<Int>()
        assertEmpty(list)
    }

    func testExtensibleCollectionType() {
        var list: ForwardList<Int> = []
        list.extend([])
        assertEmpty(list)

        list.extend([4, 5, 6])
        assert([4, 5, 6], ==, list)
    }

    func testRangeReplaceableCollectionType() {
        var list: ForwardList<Int> = []

        list.insert(1, atIndex: list.startIndex)
        assert(list, ==, [1])

        list.splice([2, 3], atIndex: list.endIndex)
        assert(list, ==, [1, 2, 3])

        list.removeAtIndex(list.startIndex)
        assert(list, ==, [2, 3])

        list.insert(1, atIndex: list.startIndex)
        assert(list, ==, [1, 2, 3])

        list.removeRange(advance(list.startIndex, 1)..<advance(list.startIndex, 2))
        assert(list, ==, [1, 3])

        list.removeRange(list.startIndex.successor()..<list.endIndex)
        assert(list, ==, [1])

        list.removeRange(list.startIndex..<list.startIndex.successor())
        assertEmpty(list)

        list.splice([1, 2, 3, 4, 5, 6], atIndex: list.endIndex)
        assert(list, ==, [1, 2, 3, 4, 5, 6])

        list.replaceRange(list.startIndex.successor()..<advance(list.startIndex, 5), with: [3])
        assert(list, ==, [1, 3, 6])

        list.replaceRange(list.startIndex..<list.endIndex, with: [3, 2, 1, 0])
        assert(list, ==, [3, 2, 1, 0])

        list.replaceRange(advance(list.startIndex, 3)..<list.endIndex, with: [1, 2, 3])
        assert(list, ==, [3, 2, 1, 1, 2, 3])

        list.removeAll(keepCapacity: false)
        assertEmpty(list)
    }

    func testRemoveFirst() {
        var list: ForwardList<Int> = [1, 2]

        assertEqual(list.removeFirst(), 1)
        assert(list, ==, [2])

        assertEqual(list.removeFirst(), 2)
        assertEmpty(list)

        list.insertLast(42)
        assert(list, ==, [42])

        assertEqual(list.removeFirst(), 42)
        assertEmpty(list)
    }

    func testHigherOrderFunctions() {
        let list: ForwardList<Int> = [1, 2, 3, 4, 5, 6]

        assert(list.map(toString), ==, ["1", "2", "3", "4", "5", "6"])
        assert(list.filter { $0 % 2 == 0 }, ==, [2, 4, 6])
        assert(list.filter { $0 % 2 == 1 }, ==, [1, 3, 5])
    }

    func assertEmpty<T>(list: ForwardList<T>, file: String = __FILE__, line: UInt = __LINE__) {
        assertEqual(list.isEmpty, true, "", file, line)
        assertNil(list.first, "", file: file, line: line)
    }
}
