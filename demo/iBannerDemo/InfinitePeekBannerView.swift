// Demo-only: 无限轮播 Peek Banner（不属于 iBanner 库）
// 原理与 iBanner 内核相同（UICollectionView 虚拟 500 * items 个 item），
// 但通过 sectionInset 实现两侧 Peek，配合 decelerationRate = .fast + 自定义 snap。

import UIKit
import SwiftUI

// MARK: - SwiftUI Wrapper

struct InfinitePeekBannerView<Item: Identifiable, Content: View>: UIViewControllerRepresentable {
    let items: [Item]
    let peekInset: CGFloat
    let itemSpacing: CGFloat
    @ViewBuilder let content: (Item) -> Content

    func makeUIViewController(context: Context) -> _InfinitePeekVC<Item, Content> {
        _InfinitePeekVC(items: items, peekInset: peekInset, itemSpacing: itemSpacing, content: content)
    }

    func updateUIViewController(_ vc: _InfinitePeekVC<Item, Content>, context: Context) {}
}

// MARK: - Cell

private final class _PeekCell<Content: View>: UICollectionViewCell {
    private(set) var hosting: UIHostingController<Content>?

    func configure(with content: Content, parent: UIViewController) {
        if let hc = hosting {
            hc.rootView = content
        } else {
            let hc = UIHostingController(rootView: content)
            hc.view.backgroundColor = .clear
            parent.addChild(hc)
            contentView.addSubview(hc.view)
            hc.view.frame = contentView.bounds
            hc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            hc.didMove(toParent: parent)
            hosting = hc
        }
    }

    func detach(from parent: UIViewController) {
        guard let hc = hosting else { return }
        hc.willMove(toParent: nil)
        hc.view.removeFromSuperview()
        hc.removeFromParent()
        hosting = nil
    }
}

// MARK: - ViewController

@MainActor
final class _InfinitePeekVC<Item: Identifiable, Content: View>: UIViewController,
    UICollectionViewDataSource, UICollectionViewDelegate {

    private let items: [Item]
    private let peekInset: CGFloat
    private let itemSpacing: CGFloat
    private let contentBuilder: (Item) -> Content

    private static var virtualMultiplier: Int { 500 }
    private var totalItems: Int { items.count * Self.virtualMultiplier }
    private var startItem: Int { items.count * Self.virtualMultiplier / 2 }

    private var collectionView: UICollectionView!
    private var flowLayout: UICollectionViewFlowLayout!

    // 相邻 item 中心间距：itemWidth + spacing
    private var cellPitch: CGFloat = 0
    private var lastSize: CGSize = .zero
    private var hasSetInitialOffset = false

    init(items: [Item], peekInset: CGFloat, itemSpacing: CGFloat, content: @escaping (Item) -> Content) {
        self.items = items
        self.peekInset = peekInset
        self.itemSpacing = itemSpacing
        self.contentBuilder = content
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("not supported") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupCollectionView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = view.bounds.size
        guard size.width > 0, size.height > 0 else { return }

        if size != lastSize {
            lastSize = size
            let itemW = size.width - 2 * peekInset
            flowLayout.itemSize = CGSize(width: itemW, height: size.height)
            cellPitch = itemW + itemSpacing

            if !hasSetInitialOffset {
                hasSetInitialOffset = true
                collectionView.contentOffset = CGPoint(x: CGFloat(startItem) * cellPitch, y: 0)
            } else {
                // 旋转：维持当前 item 位置（以 startItem 为锚）
                collectionView.contentOffset = CGPoint(x: CGFloat(startItem) * cellPitch, y: 0)
            }
        }
    }

    private func setupCollectionView() {
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = itemSpacing
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: peekInset, bottom: 0, right: peekInset)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(_PeekCell<Content>.self, forCellWithReuseIdentifier: "cell")
        collectionView.clipsToBounds = false  // 允许相邻 item 在视口外可见

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? _PeekCell<Content>, !items.isEmpty else { return }
        cell.configure(with: contentBuilder(items[indexPath.item % items.count]), parent: self)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? _PeekCell<Content>)?.detach(from: self)
    }

    // MARK: - UIScrollViewDelegate — 自定义 snap

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        guard cellPitch > 0 else { return }
        let target = targetContentOffset.pointee.x
        var snap: CGFloat
        if velocity.x > 0.3 {
            snap = ceil(target / cellPitch)
        } else if velocity.x < -0.3 {
            snap = floor(target / cellPitch)
        } else {
            snap = round(scrollView.contentOffset.x / cellPitch)
        }
        snap = max(0, min(snap, CGFloat(totalItems - 1)))
        targetContentOffset.pointee = CGPoint(x: snap * cellPitch, y: 0)
    }
}
