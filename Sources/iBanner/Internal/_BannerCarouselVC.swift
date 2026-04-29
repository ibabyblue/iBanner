// Sources/iBanner/Internal/_BannerCarouselVC.swift
import UIKit
import SwiftUI

@MainActor
final class _BannerCarouselVC<Item: Identifiable, Content: View>: UIViewController, UIScrollViewDelegate {

    // MARK: - State
    private(set) var items: [Item]
    private var contentBuilder: (Item) -> Content
    private(set) var currentIndex: Int = 0

    // MARK: - UIKit
    private let scrollView = UIScrollView()
    private var leftHosting: UIHostingController<Content>?
    private var centerHosting: UIHostingController<Content>?
    private var rightHosting: UIHostingController<Content>?
    private var isLayoutInitialized = false

    // MARK: - Auto Play
    private let timerManager = _BannerTimerManager()
    private var autoPlayInterval: TimeInterval?

    // MARK: - Callbacks (set by _BannerRepresentable.updateUIViewController)
    var onPageChanged: ((Int, Item) -> Void)?
    var onScrollProgressChanged: ((CGFloat) -> Void)?

    // MARK: - Init
    init(items: [Item], contentBuilder: @escaping (Item) -> Content) {
        self.items = items
        self.contentBuilder = contentBuilder
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("not supported") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupScrollView()
        setupHostings()
        registerAppStateNotifications()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutHostings()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAutoPlayIfNeeded()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timerManager.stop()
    }

    deinit {
        MainActor.assumeIsolated { timerManager.stop() }
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup
    private func setupScrollView() {
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.backgroundColor = .clear
        scrollView.delegate = self
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupHostings() {
        if items.count <= 1 {
            setupSingleOrEmptyPage()
        } else {
            setupThreePages()
        }
    }

    private func setupSingleOrEmptyPage() {
        guard !items.isEmpty else { return }
        let hosting = makeHosting(at: 0)
        attach(hosting)
        centerHosting = hosting
        scrollView.isScrollEnabled = false
    }

    private func setupThreePages() {
        let count = items.count
        let left = makeHosting(at: _BannerIndexCalculator.leftIndex(current: currentIndex, count: count))
        let center = makeHosting(at: currentIndex)
        let right = makeHosting(at: _BannerIndexCalculator.rightIndex(current: currentIndex, count: count))
        [left, center, right].forEach { attach($0) }
        leftHosting = left
        centerHosting = center
        rightHosting = right
    }

    private func layoutHostings() {
        let w = view.bounds.width
        let h = view.bounds.height
        guard w > 0, h > 0 else { return }

        if items.count > 1 {
            scrollView.contentSize = CGSize(width: w * 3, height: h)
            leftHosting?.view.frame   = CGRect(x: 0,       y: 0, width: w, height: h)
            centerHosting?.view.frame = CGRect(x: w,       y: 0, width: w, height: h)
            rightHosting?.view.frame  = CGRect(x: w * 2,   y: 0, width: w, height: h)
            if !isLayoutInitialized {
                scrollView.contentOffset = CGPoint(x: w, y: 0)
                isLayoutInitialized = true
            }
        } else {
            scrollView.contentSize = CGSize(width: w, height: h)
            centerHosting?.view.frame = CGRect(x: 0, y: 0, width: w, height: h)
        }
    }

    // MARK: - Helpers
    private func makeHosting(at index: Int) -> UIHostingController<Content> {
        let hosting = UIHostingController(rootView: contentBuilder(items[index]))
        hosting.view.backgroundColor = .clear
        return hosting
    }

    private func attach(_ hosting: UIHostingController<Content>) {
        addChild(hosting)
        scrollView.addSubview(hosting.view)
        hosting.didMove(toParent: self)
    }

    private func detachAll() {
        [leftHosting, centerHosting, rightHosting].compactMap { $0 }.forEach {
            $0.willMove(toParent: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
        leftHosting = nil
        centerHosting = nil
        rightHosting = nil
    }

    private func refreshPageContents() {
        let count = items.count
        leftHosting?.rootView   = contentBuilder(items[_BannerIndexCalculator.leftIndex(current: currentIndex, count: count)])
        centerHosting?.rootView = contentBuilder(items[currentIndex])
        rightHosting?.rootView  = contentBuilder(items[_BannerIndexCalculator.rightIndex(current: currentIndex, count: count)])
    }

    // MARK: - Auto Play
    func setAutoPlay(interval: TimeInterval?) {
        autoPlayInterval = interval
        timerManager.stop()
        startAutoPlayIfNeeded()
    }

    private func startAutoPlayIfNeeded() {
        guard let interval = autoPlayInterval, interval > 0, items.count > 1 else { return }
        timerManager.start(interval: interval) { [weak self] in
            self?.scrollToNext()
        }
    }

    private func scrollToNext() {
        let w = view.bounds.width
        // 向右滑动到第三页（右侧 slot）
        scrollView.setContentOffset(CGPoint(x: w * 2, y: 0), animated: true)
    }

    // MARK: - Update (called from updateUIViewController)
    func update(items newItems: [Item], contentBuilder newBuilder: @escaping (Item) -> Content) {
        let oldIDs = items.map(\.id)
        let newIDs = newItems.map(\.id)
        contentBuilder = newBuilder
        items = newItems

        if oldIDs != newIDs {
            // 数据源变化：重建三页，index 归零
            currentIndex = 0
            isLayoutInitialized = false
            timerManager.stop()
            detachAll()
            setupHostings()
            layoutHostings()
        } else {
            // 仅数据内容变化（如图片 URL 更新）：刷新内容
            refreshPageContents()
        }
    }

    // MARK: - App State
    private func registerAppStateNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    @objc private func appDidEnterBackground() {
        timerManager.stop()
    }

    @objc private func appWillEnterForeground() {
        startAutoPlayIfNeeded()
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timerManager.pause()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard items.count > 1 else { return }
        let w = view.bounds.width
        guard w > 0 else { return }
        let progress = (scrollView.contentOffset.x - w) / w  // -1...1
        onScrollProgressChanged?(progress)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleScrollEnd(scrollView)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        handleScrollEnd(scrollView)
    }

    private func handleScrollEnd(_ scrollView: UIScrollView) {
        guard items.count > 1 else { return }
        let w = view.bounds.width
        let newIndex = _BannerIndexCalculator.updatedIndex(
            currentIndex: currentIndex,
            contentOffsetX: scrollView.contentOffset.x,
            pageWidth: w,
            count: items.count
        )

        if newIndex != currentIndex {
            currentIndex = newIndex
            refreshPageContents()
            scrollView.setContentOffset(CGPoint(x: w, y: 0), animated: false)
            onPageChanged?(currentIndex, items[currentIndex])
        }

        // 无论是否换页都重置定时器（手动滑到同位置时也重置）
        timerManager.reset()
    }
}
