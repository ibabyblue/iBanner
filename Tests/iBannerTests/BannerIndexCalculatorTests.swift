import XCTest
@testable import iBanner

final class BannerIndexCalculatorTests: XCTestCase {

    func test_leftIndex_from_first_wrapsToLast() {
        XCTAssertEqual(_BannerIndexCalculator.leftIndex(current: 0, count: 3), 2)
    }

    func test_leftIndex_from_middle() {
        XCTAssertEqual(_BannerIndexCalculator.leftIndex(current: 1, count: 3), 0)
    }

    func test_leftIndex_from_last() {
        XCTAssertEqual(_BannerIndexCalculator.leftIndex(current: 2, count: 3), 1)
    }

    func test_rightIndex_from_last_wrapsToFirst() {
        XCTAssertEqual(_BannerIndexCalculator.rightIndex(current: 2, count: 3), 0)
    }

    func test_rightIndex_from_first() {
        XCTAssertEqual(_BannerIndexCalculator.rightIndex(current: 0, count: 3), 1)
    }

    func test_updatedIndex_atCenter_returnsCurrent() {
        // offset == pageWidth → no movement
        XCTAssertEqual(
            _BannerIndexCalculator.updatedIndex(currentIndex: 1, contentOffsetX: 100, pageWidth: 100, count: 3),
            1
        )
    }

    func test_updatedIndex_scrollRight_incrementsIndex() {
        XCTAssertEqual(
            _BannerIndexCalculator.updatedIndex(currentIndex: 0, contentOffsetX: 200, pageWidth: 100, count: 3),
            1
        )
    }

    func test_updatedIndex_scrollLeft_decrementsIndex() {
        XCTAssertEqual(
            _BannerIndexCalculator.updatedIndex(currentIndex: 1, contentOffsetX: 0, pageWidth: 100, count: 3),
            0
        )
    }

    func test_updatedIndex_scrollRight_wrapsAround() {
        XCTAssertEqual(
            _BannerIndexCalculator.updatedIndex(currentIndex: 2, contentOffsetX: 200, pageWidth: 100, count: 3),
            0
        )
    }

    func test_updatedIndex_scrollLeft_wrapsAround() {
        XCTAssertEqual(
            _BannerIndexCalculator.updatedIndex(currentIndex: 0, contentOffsetX: 0, pageWidth: 100, count: 3),
            2
        )
    }
}
