# iBanner

A universal infinite-scroll banner component for iOS 17+. UICollectionView virtual-section core, SwiftUI public API, zero third-party dependencies.

## Requirements

- iOS 17+
- Swift 5.9+
- Xcode 15+

## Installation

### Swift Package Manager

In Xcode choose **File → Add Package Dependencies**, enter the repository URL, or add it directly to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ibabyblue/iBanner", from: "0.0.2")
]
```

## Quick Start

### Custom View (recommended)

```swift
import iBanner

BannerView(items: items) { item in
    MyCard(item: item)
}
.bannerAutoPlay(interval: 3)
.bannerIndicator(.capsule())
.onBannerPageChanged { index, item in
    print("Current page: \(index)")
}
.frame(height: 200)
```

### Built-in Template (Item conforms to BannerDisplayable)

```swift
// Declare your model
struct Banner: BannerDisplayable {
    var id: Int
    var imageURL: URL?
    var title: String?
    var subtitle: String?
}

// Use it out of the box
BannerView(items: banners)
    .bannerIndicator(.dot(activeColor: .white))
    .frame(height: 200)
```

### Fully Custom Indicator

```swift
BannerView(items: items) { item in
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

### BannerDisplayable

Built-in template protocol — all fields are optional:

```swift
public protocol BannerDisplayable: Identifiable {
    var imageURL: URL? { get }    // async-loaded via system AsyncImage
    var title: String? { get }    // overlaid at the bottom of the image
    var subtitle: String? { get } // below title, smaller font
}
```

### View Modifiers

| Modifier | Description | Default |
|---|---|---|
| `.bannerAutoPlay(interval:)` | Auto-play interval; `nil` or `0` disables it | `3` (seconds) |
| `.bannerIndicator(_ style:)` | Built-in indicator style | `.dot()` |
| `.bannerIndicatorAlignment(_ alignment:)` | Indicator position | `.bottom` |
| `.onBannerPageChanged(_ action:)` | Page-change callback, returns both index and item | — |

### BannerIndicatorStyle

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
| `items` replaced at runtime | Resets the collection view, `currentIndex` returns to 0 |
| App enters background | Timer pauses; resumes automatically on foreground |

## Demo

Open `demo/iBannerDemo.xcodeproj`, select a simulator and run. Includes:

- Custom view + Dot / Capsule / numeric indicator
- Auto-play disabled, manual swipe only
- Peek effect — infinite scroll variant and native ScrollView variant

## Design Notes

- Core: UICollectionView with 500 virtual sections × real item count. `isPagingEnabled = true` lets the system handle all paging and deceleration natively — fast consecutive swiping works out of the box.
- The public API is entirely SwiftUI; callers have no exposure to UIKit.
- Image loading uses the system `AsyncImage` — zero third-party dependencies.
- The capsule indicator interpolates color and width in sync with `scrollProgress` (`contentOffset / pageWidth − stableGlobalItem`), producing smooth finger-tracking animation.

## Out of Scope

- Image caching (integrate Kingfisher / SDWebImage in your custom view)
- Parallax scrolling, peek effect (see the Demo for the native ScrollView implementation)
- Vertical scrolling
- macOS / tvOS
