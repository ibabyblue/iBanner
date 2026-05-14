import UIKit
import SwiftUI

// MARK: - Cell

private final class _BannerCell<Content: View>: UICollectionViewCell {

    private(set) var hostingController: UIHostingController<Content>?

    func configure(with content: Content, parent: UIViewController) {
        if let hc = hostingController {
            hc.rootView = content
        } else {
            let hc = UIHostingController(rootView: content)
            hc.view.backgroundColor = .clear
            parent.addChild(hc)
            contentView.addSubview(hc.view)
            hc.view.frame = contentView.bounds
            hc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            hc.didMove(toParent: parent)
            hostingController = hc
        }
    }

    func detach(from parent: UIViewController) {
        guard let hc = hostingController else { return }
        hc.willMove(toParent: nil)
        hc.view.removeFromSuperview()
        hc.removeFromParent()
        hostingController = nil
    }
}

// MARK: - ViewController
//
// 无限轮播内核：UICollectionView 虚拟 500 个 section，每 section 包含真实 items。
// isPagingEnabled 由系统处理所有翻页与减速，快速连续滑动天然支持，无需手动 reset contentOffset。

@MainActor
final class _BannerCarouselVC<Item: Identifiable, Content: View>: UIViewController,
    UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - State

    private(set) var items: [Item]
    private var contentBuilder: (Item) -> Content
    private(set) var currentIndex: Int = 0

    // 虚拟 section 总数；从中间 section 出发，两端各可滑动 250 轮，实际无限
    private static var totalSections: Int { 500 }
    private var startSection: Int { Self.totalSections / 2 }

    // 当前稳定停留的全局 item 下标（跨所有虚拟 section）
    private var stableGlobalItem: Int = 0
    private var lastLayoutSize: CGSize = .zero
    private var hasSetInitialOffset = false

    // MARK: - UIKit

    private var collectionView: UICollectionView!
    private var flowLayout: UICollectionViewFlowLayout!

    // MARK: - Auto Play

    private let timerManager = _BannerTimerManager()
    private var autoPlayInterval: TimeInterval?

    // MARK: - Callbacks

    /// 页面稳定落点时触发，同时更新指示器并调用用户的 onBannerPageChanged
    var onPageChanged: ((Int, Item) -> Void)?
    /// 拖拽提前提交最近页时触发，仅更新指示器（dot），不触发用户回调
    var onCurrentIndexChanged: ((Int) -> Void)?
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
        setupCollectionView()
        registerAppStateNotifications()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = view.bounds.size
        guard size.width > 0, size.height > 0 else { return }

        let sizeChanged = size != lastLayoutSize
        lastLayoutSize = size
        flowLayout.itemSize = size

        guard items.count > 1 else { return }

        if !hasSetInitialOffset {
            hasSetInitialOffset = true
            stableGlobalItem = startSection * items.count + currentIndex
            collectionView.contentOffset = CGPoint(x: CGFloat(stableGlobalItem) * size.width, y: 0)
        } else if sizeChanged {
            // 旋转或尺寸变化时，按 stableGlobalItem 重新对齐
            collectionView.contentOffset = CGPoint(x: CGFloat(stableGlobalItem) * size.width, y: 0)
        }
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
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    private func setupCollectionView() {
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.bounces = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(_BannerCell<Content>.self, forCellWithReuseIdentifier: "cell")
        collectionView.isScrollEnabled = items.count > 1

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
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
        guard w > 0 else { return }
        collectionView.setContentOffset(
            CGPoint(x: CGFloat(stableGlobalItem + 1) * w, y: 0),
            animated: true
        )
    }

    // MARK: - Update (called from _BannerRepresentable.updateUIViewController)

    func update(items newItems: [Item], contentBuilder newBuilder: @escaping (Item) -> Content) {
        let oldIDs = items.map(\.id)
        let newIDs = newItems.map(\.id)
        contentBuilder = newBuilder
        items = newItems

        if oldIDs != newIDs {
            currentIndex = 0
            hasSetInitialOffset = false
            timerManager.stop()
            collectionView.isScrollEnabled = newItems.count > 1
            collectionView.reloadData()
            view.setNeedsLayout()
        } else {
            // 仅内容变化（如图片 URL 更新），刷新可见 cell
            for case let cell as _BannerCell<Content> in collectionView.visibleCells {
                guard let indexPath = collectionView.indexPath(for: cell) else { continue }
                cell.configure(with: contentBuilder(items[indexPath.item]), parent: self)
            }
        }
    }

    // MARK: - App State

    private func registerAppStateNotifications() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc private func appDidEnterBackground() { timerManager.stop() }
    @objc private func appWillEnterForeground() { startAutoPlayIfNeeded() }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        items.count > 1 ? Self.totalSections : 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? _BannerCell<Content>, !items.isEmpty else { return }
        cell.configure(with: contentBuilder(items[indexPath.item]), parent: self)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? _BannerCell<Content>)?.detach(from: self)
    }

    // MARK: - UIScrollViewDelegate (via UICollectionViewDelegate)

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timerManager.pause()
        // 新一次拖拽打断上次减速时，把 stableGlobalItem 对齐到最近页。
        // currentIndex 与 scrollProgress 必须在同一 UIKit 回调里同步更新，
        // 让 SwiftUI 批进同一 render cycle，避免 capsule 出现错位帧。
        guard items.count > 1, hasSetInitialOffset else { return }
        let w = view.bounds.width
        guard w > 0 else { return }
        let nearest = Int(round(scrollView.contentOffset.x / w))
        guard nearest != stableGlobalItem else { return }
        stableGlobalItem = nearest
        // 先更新 progress（与 currentIndex 同帧），避免 capsule 闪烁
        let newProgress = max(-1, min(1, scrollView.contentOffset.x / w - CGFloat(nearest)))
        onScrollProgressChanged?(newProgress)
        let newDataIndex = nearest % items.count
        if newDataIndex != currentIndex {
            currentIndex = newDataIndex
            onCurrentIndexChanged?(currentIndex)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard items.count > 1, hasSetInitialOffset else { return }
        let w = view.bounds.width
        guard w > 0 else { return }
        // 夹到 -1...1：单次拖拽跨页时的兜底，避免 capsule 宽度越界
        let raw = scrollView.contentOffset.x / w - CGFloat(stableGlobalItem)
        onScrollProgressChanged?(max(-1, min(1, raw)))
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { handleScrollEnd(scrollView) }
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
        guard w > 0 else { return }

        let newGlobalItem = Int(round(scrollView.contentOffset.x / w))
        let newDataIndex = newGlobalItem % items.count
        stableGlobalItem = newGlobalItem

        // progress 必须与 currentIndex 在同一 UIKit 回调里归零，
        // 让 SwiftUI 批进同一 render cycle，避免 capsule 出现跳两次的错位帧。
        onScrollProgressChanged?(0)

        if newDataIndex != currentIndex {
            currentIndex = newDataIndex
            onPageChanged?(currentIndex, items[currentIndex])
        }

        timerManager.reset()
    }
}
