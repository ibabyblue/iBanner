import Foundation

@MainActor
final class _BannerTimerManager {
    private var source: DispatchSourceTimer?
    private var isSuspended = false
    private var action: (() -> Void)?
    private var interval: TimeInterval = 0

    func start(interval: TimeInterval, action: @escaping () -> Void) {
        guard interval > 0 else { return }
        stop()
        self.interval = interval
        self.action = action
        schedule()
    }

    func pause() {
        guard let source, !isSuspended else { return }
        source.suspend()
        isSuspended = true
    }

    func resume() {
        guard let source, isSuspended else { return }
        source.resume()
        isSuspended = false
    }

    func reset() {
        guard action != nil, interval > 0 else { return }
        stop()
        schedule()
    }

    func stop() {
        guard let source else { return }
        if isSuspended { source.resume() }  // cancel 前必须 resume，否则崩溃
        source.cancel()
        self.source = nil
        isSuspended = false
    }

    private func schedule() {
        let t = DispatchSource.makeTimerSource(queue: .main)
        t.schedule(deadline: .now() + interval, repeating: .infinity)
        t.setEventHandler { [weak self] in self?.action?() }
        t.resume()
        isSuspended = false
        source = t
    }

    deinit {
        if let source {
            if isSuspended { source.resume() }
            source.cancel()
        }
    }
}
