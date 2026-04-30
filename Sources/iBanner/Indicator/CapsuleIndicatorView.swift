import SwiftUI
import UIKit

struct CapsuleIndicatorView: View {
    let currentIndex: Int
    let total: Int
    let scrollProgress: CGFloat      // -1...1
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
        // 只在 currentIndex 变化（页面稳定后）时触发 spring 动画；
        // scrollProgress 变化（手指滑动中）时直接跟手，不走动画
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: currentIndex)
    }

    // MARK: - Width（跟手实时，无动画）

    private func widthFor(_ index: Int) -> CGFloat {
        let progress = abs(scrollProgress)
        let delta = expandedWidth - dotSize
        if index == currentIndex {
            return expandedWidth - progress * delta
        }
        guard scrollProgress != 0 else { return dotSize }
        let target = targetIndex
        return index == target ? dotSize + progress * delta : dotSize
    }

    // MARK: - Color（与 width 同步插值，大 capsule 也是 activeColor）

    private func colorFor(_ index: Int) -> Color {
        lerp(inactiveColor, activeColor, activeFraction(for: index))
    }

    // 0.0 = 完全 inactive, 1.0 = 完全 active
    private func activeFraction(for index: Int) -> CGFloat {
        let progress = abs(scrollProgress)
        if index == currentIndex { return max(0, 1 - progress) }
        guard scrollProgress != 0, index == targetIndex else { return 0 }
        return progress
    }

    private var targetIndex: Int {
        scrollProgress > 0
            ? (currentIndex + 1) % total
            : (currentIndex - 1 + total) % total
    }

    // MARK: - Color Lerp（sRGB 空间插值，兼容任意颜色组合）

    private func lerp(_ a: Color, _ b: Color, _ t: CGFloat) -> Color {
        guard t > 0 else { return a }
        guard t < 1 else { return b }
        var ar: CGFloat = 0, ag: CGFloat = 0, ab: CGFloat = 0, aa: CGFloat = 0
        var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
        UIColor(a).getRed(&ar, green: &ag, blue: &ab, alpha: &aa)
        UIColor(b).getRed(&br, green: &bg, blue: &bb, alpha: &ba)
        return Color(
            red:     Double(ar + (br - ar) * t),
            green:   Double(ag + (bg - ag) * t),
            blue:    Double(ab + (bb - ab) * t),
            opacity: Double(aa + (ba - aa) * t)
        )
    }
}
