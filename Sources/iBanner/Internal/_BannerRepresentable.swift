// Sources/iBanner/Internal/_BannerRepresentable.swift
import SwiftUI

struct _BannerRepresentable<Item: Identifiable, Content: View>: UIViewControllerRepresentable {
    let items: [Item]
    let contentBuilder: (Item) -> Content
    let autoPlayInterval: TimeInterval?
    @Binding var currentIndex: Int
    @Binding var scrollProgress: CGFloat
    let onPageChanged: ((Int, Item) -> Void)?

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIViewController(context: Context) -> _BannerCarouselVC<Item, Content> {
        let vc = _BannerCarouselVC(items: items, contentBuilder: contentBuilder)
        updateCallbacks(on: vc)
        return vc
    }

    func updateUIViewController(_ vc: _BannerCarouselVC<Item, Content>, context: Context) {
        let oldIDs = vc.items.map(\.id)
        let newIDs = items.map(\.id)
        vc.update(items: items, contentBuilder: contentBuilder)
        vc.setAutoPlay(interval: autoPlayInterval)
        if oldIDs != newIDs {
            currentIndex = 0
        }
        updateCallbacks(on: vc)
    }

    private func updateCallbacks(on vc: _BannerCarouselVC<Item, Content>) {
        vc.onPageChanged = { [onPageChanged] index, item in
            currentIndex = index
            onPageChanged?(index, item)
        }
        vc.onScrollProgressChanged = { progress in
            scrollProgress = progress
        }
    }

    class Coordinator {}
}
