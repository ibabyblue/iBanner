import SwiftUI

struct CapsuleIndicatorView: View {
    let currentIndex: Int
    let total: Int
    let scrollProgress: CGFloat      // -1...1, from UIScrollView
    var activeColor: Color = .white
    var inactiveColor: Color = .white.opacity(0.35)
    var dotSize: CGFloat = 8
    var expandedWidth: CGFloat = 22
    var spacing: CGFloat = 5

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(colorFor(index))
                    .frame(width: widthFor(index), height: dotSize)
            }
        }
        // 使用 animation 而非 withAnimation，让 scrollProgress 变化时自动插值
        .animation(.linear(duration: 0.05), value: scrollProgress)
    }

    private func widthFor(_ index: Int) -> CGFloat {
        let progress = abs(scrollProgress)
        let delta = expandedWidth - dotSize

        if index == currentIndex {
            // 当前页：随滑动进度收窄
            return expandedWidth - progress * delta
        }

        let targetIndex: Int
        if scrollProgress > 0 {
            targetIndex = (currentIndex + 1) % total
        } else if scrollProgress < 0 {
            targetIndex = (currentIndex - 1 + total) % total
        } else {
            return dotSize
        }

        if index == targetIndex {
            // 目标页：随滑动进度扩展
            return dotSize + progress * delta
        }

        return dotSize
    }

    private func colorFor(_ index: Int) -> Color {
        index == currentIndex ? activeColor : inactiveColor
    }
}
