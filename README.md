# IBanner

A universal infinite-scroll banner component for iOS 17+. UICollectionView virtual-section core, SwiftUI public API, zero third-party dependencies.

![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue)
![Swift 5.9](https://img.shields.io/badge/Swift-5.9%2B-orange)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

## Features

- **Type-safe API** — generic over any `Identifiable` item type; no stringly-typed configuration
- **Three indicator styles** — Dot, Capsule (finger-tracking animation), or fully custom
- **Infinite scroll** — UICollectionView virtual-section core; fast consecutive swiping works natively
- **Auto-play** — configurable interval with automatic pause/resume on app background/foreground transitions
- **Built-in template** — drop-in image + title + subtitle layout via `IBannerDisplayable`
- **Zero third-party dependencies** — system `AsyncImage` for image loading

## Requirements

| | Minimum |
|---|---|
| iOS | 17.0 |
| Swift | 5.9 |
| Xcode | 15.0 |

## Installation

### Swift Package Manager

In Xcode choose **File → Add Package Dependencies**, enter the repository URL, or add to `Package.swift` directly:

```swift
dependencies: [
    .package(url: "https://github.com/ibabyblue/IBanner", from: "0.0.5")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "IBanner", package: "IBanner")
        ]
    )
]
```

## Quick Start

### Custom View (recommended)

```swift
import IBanner

IBannerView(items: items) { item in
    MyCard(item: item)
}
.bannerAutoPlay(interval: 3)
.bannerIndicator(.capsule())
.onBannerPageChanged { index, item in
    print("Current page: \(index)")
}
.frame(height: 200)
```

### Built-in Template (Item conforms to IBannerDisplayable)

```swift
// Declare your model
struct Banner: IBannerDisplayable {
    var id: Int
    var imageURL: URL?
    var title: String?
    var subtitle: String?
}

// Use it out of the box
IBannerView(items: banners)
    .bannerIndicator(.dot(activeColor: .white))
    .frame(height: 200)
```

### Fully Custom Indicator

```swift
IBannerView(items: items) { item in
    MyCard(item: item)
} indicator: { index, total in
    Text("\(index + 1) / \(total)")
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(.black.opacity(0.4), in: Capsule())
}
```

## API Reference

### IBannerView

```swift
public struct IBannerView<Item: Identifiable, Content: View>: View {

    // Custom view + built-in indicator
    public init(items: [Item], @ViewBuilder content: @escaping (Item) -> Content)

    // Custom view + custom indicator
    public init<Indicator: View>(
        items: [Item],
        @ViewBuilder content: @escaping (Item) -> Content,
        @ViewBuilder indicator: @escaping (_ currentIndex: Int, _ total: Int) -> Indicator
    )
}
```

### IBannerDisplayable

Built-in template protocol — all fields are optional:

```swift
public protocol IBannerDisplayable: Identifiable {
    var imageURL: URL? { get }    // loaded asynchronously via system AsyncImage
    var title: String? { get }    // overlaid at the bottom of the image
    var subtitle: String? { get } // below title, smaller font
}
```

### View Modifiers

| Modifier | Description | Default |
|---|---|---|
| `.bannerAutoPlay(interval:)` | Auto-play interval in seconds; `nil` or `0` disables it | `3` |
| `.bannerIndicator(_ style:)` | Built-in indicator style | `.dot()` |
| `.bannerIndicatorAlignment(_ alignment:)` | Indicator position within the banner | `.bottom` |
| `.onBannerPageChanged(_ action:)` | Page-change callback; receives both index and item | — |

### IBannerIndicatorStyle

```swift
// Dot: active page highlighted, others semi-transparent
.dot(
    activeColor: Color = .white,
    inactiveColor: Color = .white.opacity(0.35),
    size: CGFloat = 8,
    spacing: CGFloat = 6
)

// Capsule: active page stretches into a capsule, follows finger in real time
.capsule(
    activeColor: Color = .white,
    inactiveColor: Color = .white.opacity(0.35),
    dotSize: CGFloat = 8,
    expandedWidth: CGFloat = 22,
    spacing: CGFloat = 5
)
```

## Edge-Case Behavior

| Scenario | Behavior |
|---|---|
| `items` is empty | Renders a blank view, no crash |
| `items.count == 1` | Scroll disabled, no indicator, no auto-play |
| `items` replaced at runtime | Resets the collection view; `currentIndex` returns to `0` |
| App enters background | Timer pauses; resumes automatically on foreground |

## Demo

Open `demo/IBannerDemo.xcodeproj`, select a simulator and run. Covers two scenarios:

- **Full-Screen** — custom view + Dot / Capsule / numeric indicator; auto-play on/off
- **Peek** — infinite-scroll Peek (virtual-section core) and native `ScrollView` Peek variants

## Design Notes

- Core: `UICollectionView` with 500 virtual sections × real item count. `isPagingEnabled = true` lets the system handle all paging and deceleration natively — fast consecutive swiping works out of the box.
- The public API is entirely SwiftUI; callers have no exposure to UIKit internals.
- Image loading uses the system `AsyncImage` — zero third-party dependencies.
- The capsule indicator interpolates color and width in sync with `scrollProgress` (`contentOffset / pageWidth − stableGlobalItem`), producing smooth finger-tracking animation with no layout passes.

## Out of Scope

- Image caching (integrate Kingfisher / SDWebImage in your custom view)
- Parallax scrolling, peek effect (see the Demo for a reference implementation)
- Vertical scrolling
- macOS / tvOS / watchOS

## License

IBanner is available under the MIT license. See the [LICENSE](LICENSE) file for details.
