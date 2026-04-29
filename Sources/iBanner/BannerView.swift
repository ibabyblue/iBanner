// Sources/iBanner/BannerView.swift
import SwiftUI

public struct BannerView<Item: Identifiable, Content: View>: View {

    // MARK: - Data
    private let items: [Item]
    private let contentBuilder: (Item) -> Content
    private var customIndicator: ((Int, Int) -> AnyView)?

    // MARK: - Configuration (set via modifiers)
    private var autoPlayInterval: TimeInterval? = 3
    private var indicatorStyle: BannerIndicatorStyle = .dot()
    private var indicatorAlignment: Alignment = .bottom
    private var onPageChangedHandler: ((Int, Item) -> Void)?

    // MARK: - State
    @State private var currentIndex: Int = 0
    @State private var scrollProgress: CGFloat = 0

    // MARK: - Init: custom view, built-in indicator
    public init(
        items: [Item],
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.contentBuilder = content
    }

    // MARK: - Body
    public var body: some View {
        ZStack(alignment: indicatorAlignment) {
            _BannerRepresentable(
                items: items,
                contentBuilder: contentBuilder,
                autoPlayInterval: autoPlayInterval,
                currentIndex: $currentIndex,
                scrollProgress: $scrollProgress,
                onPageChanged: onPageChangedHandler
            )

            if items.count > 1 {
                indicatorView
                    .padding(.bottom, 12)
            }
        }
    }

    @ViewBuilder
    private var indicatorView: some View {
        if let customIndicator {
            customIndicator(currentIndex, items.count)
        } else {
            switch indicatorStyle {
            case let .dot(activeColor, inactiveColor, size, spacing):
                DotIndicatorView(
                    currentIndex: currentIndex,
                    total: items.count,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    size: size,
                    spacing: spacing
                )
            case let .capsule(activeColor, inactiveColor, dotSize, expandedWidth, spacing):
                CapsuleIndicatorView(
                    currentIndex: currentIndex,
                    total: items.count,
                    scrollProgress: scrollProgress,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    dotSize: dotSize,
                    expandedWidth: expandedWidth,
                    spacing: spacing
                )
            }
        }
    }
}

// MARK: - Init: custom view + custom indicator
extension BannerView {
    public init<Indicator: View>(
        items: [Item],
        @ViewBuilder content: @escaping (Item) -> Content,
        @ViewBuilder indicator: @escaping (_ currentIndex: Int, _ total: Int) -> Indicator
    ) {
        self.items = items
        self.contentBuilder = content
        self.customIndicator = { idx, total in AnyView(indicator(idx, total)) }
    }
}

// MARK: - Init: built-in template (Item: BannerDisplayable)
extension BannerView where Item: BannerDisplayable, Content == _BannerStandardTemplateView<Item> {
    // Cannot be `public` because the constraint references the internal type _BannerStandardTemplateView.
    // Callers use BannerView(items:) and type inference resolves to this overload at the call site.
    init(items: [Item]) {
        self.init(items: items) { item in
            _BannerStandardTemplateView(item: item)
        }
    }
}

// MARK: - View Modifiers
extension BannerView {

    public func bannerAutoPlay(interval: TimeInterval?) -> BannerView {
        var copy = self
        copy.autoPlayInterval = interval
        return copy
    }

    public func bannerIndicator(_ style: BannerIndicatorStyle) -> BannerView {
        var copy = self
        copy.indicatorStyle = style
        return copy
    }

    public func bannerIndicatorAlignment(_ alignment: Alignment) -> BannerView {
        var copy = self
        copy.indicatorAlignment = alignment
        return copy
    }

    public func onBannerPageChanged(_ action: @escaping (Int, Item) -> Void) -> BannerView {
        var copy = self
        copy.onPageChangedHandler = action
        return copy
    }
}
