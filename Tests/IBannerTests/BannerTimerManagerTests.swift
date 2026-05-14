import XCTest
@testable import IBanner

@MainActor
final class BannerTimerManagerTests: XCTestCase {

    func test_start_firesAfterInterval() {
        let sut = _BannerTimerManager()
        let exp = expectation(description: "fires")
        sut.start(interval: 0.05) { exp.fulfill() }
        wait(for: [exp], timeout: 0.5)
    }

    func test_stop_preventsAllFires() {
        let sut = _BannerTimerManager()
        var fired = false
        sut.start(interval: 0.05) { fired = true }
        sut.stop()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.15))
        XCTAssertFalse(fired)
    }

    func test_pause_holdsTimer_resumeLetsFire() {
        let sut = _BannerTimerManager()
        let exp = expectation(description: "fires after resume")
        sut.start(interval: 0.05) { exp.fulfill() }
        sut.pause()
        // GCD timer suspended — pending event accumulates; resume immediately fires it
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        sut.resume()
        wait(for: [exp], timeout: 0.5)
    }

    func test_reset_restartsCountdown() {
        let sut = _BannerTimerManager()
        var fireCount = 0
        sut.start(interval: 0.1) { fireCount += 1 }
        // 在第一次触发前 reset
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
        sut.reset()
        // reset 后再等 0.05s，仍不应触发（新的 0.1s 周期尚未到）
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
        XCTAssertEqual(fireCount, 0)
        // reset 后等完整 0.1s，应触发一次
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.08))
        XCTAssertEqual(fireCount, 1)
    }

    func test_startWithZeroInterval_neverFires() {
        let sut = _BannerTimerManager()
        var fired = false
        sut.start(interval: 0) { fired = true }
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        XCTAssertFalse(fired)
    }
}
