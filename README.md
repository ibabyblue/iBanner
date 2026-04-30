# iBanner

iOS 17+ 通用 Banner 无限轮播组件，UICollectionView 虚拟无限 section 内核，SwiftUI 对外接口，零三方依赖。

## 要求

- iOS 17+
- Swift 5.9+
- Xcode 15+

## 安装

### Swift Package Manager

在 Xcode 中选择 **File → Add Package Dependencies**，输入仓库地址，或在 `Package.swift` 中添加：

```swift
dependencies: [
    .package(url: "https://github.com/ibabyblue/iBanner", from: "0.0.2")
]
```

## 快速上手

### 自定义 View（推荐）

```swift
import iBanner

BannerView(items: items) { item in
    MyCard(item: item)
}
.bannerAutoPlay(interval: 3)
.bannerIndicator(.capsule())
.onBannerPageChanged { index, item in
    print("当前页: \(index)")
}
.frame(height: 200)
```

### 内置模板（Item 遵循 BannerDisplayable）

```swift
// 声明数据模型
struct Banner: BannerDisplayable {
    var id: Int
    var imageURL: URL?
    var title: String?
    var subtitle: String?
}

// 直接使用，开箱即用
BannerView(items: banners)
    .bannerIndicator(.dot(activeColor: .white))
    .frame(height: 200)
```

### 完全自定义指示器

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

## API 参考

### BannerDisplayable

内置模板协议，所有字段均可选：

```swift
public protocol BannerDisplayable: Identifiable {
    var imageURL: URL? { get }   // 异步加载，使用系统 AsyncImage
    var title: String? { get }   // 叠加在图片底部
    var subtitle: String? { get } // title 下方，字号更小
}
```

### View Modifiers

| Modifier | 说明 | 默认值 |
|---|---|---|
| `.bannerAutoPlay(interval:)` | 自动播放间隔，`nil` 或 `0` 关闭 | `3`（秒）|
| `.bannerIndicator(_ style:)` | 内置指示器样式 | `.dot()` |
| `.bannerIndicatorAlignment(_ alignment:)` | 指示器位置 | `.bottom` |
| `.onBannerPageChanged(_ action:)` | 翻页回调，同时返回 index 和 item | — |

### BannerIndicatorStyle

```swift
// 圆点：当前页高亮，其余半透明
.dot(
    activeColor: Color = .white,
    inactiveColor: Color = .white.opacity(0.35),
    size: CGFloat = 8,
    spacing: CGFloat = 6
)

// 胶囊：当前页拉伸为胶囊，支持跟手动画
.capsule(
    activeColor: Color = .white,
    inactiveColor: Color = .white.opacity(0.35),
    dotSize: CGFloat = 8,
    expandedWidth: CGFloat = 22,
    spacing: CGFloat = 5
)
```

## 边界行为

| 场景 | 行为 |
|---|---|
| `items` 为空 | 渲染空白 View，不崩溃 |
| `items.count == 1` | 禁用滑动，不显示指示器，不自动播放 |
| `items` 运行时替换 | 重置 collection view，`currentIndex` 归零 |
| App 进入后台 | 定时器暂停，回到前台自动恢复 |

## Demo

打开 `demo/iBannerDemo.xcodeproj`，选择模拟器运行，包含以下示例：

- 自定义 View + Dot / Capsule / 数字指示器
- 禁用自动播放，手动滑动
- Peek 效果（iOS 17 原生 ScrollView）

## 设计说明

- 内核为 UICollectionView 虚拟多 section（500 个 section × 真实 item 数），`isPagingEnabled = true` 由系统处理所有翻页与减速，快速连续滑动天然支持
- 对外接口完全 SwiftUI 化，使用方感知不到 UIKit
- 图片加载使用系统 `AsyncImage`，零三方依赖
- Capsule 指示器通过 `scrollProgress`（`contentOffset / pageWidth - stableGlobalItem`）实现逐帧跟手动画

## 不在范围内

- 图片缓存（可在自定义 View 中接入 Kingfisher / SDWebImage）
- 视差滚动、Peek 效果（见 Demo 中的原生 ScrollView 实现）
- 竖向滚动
- macOS / tvOS
