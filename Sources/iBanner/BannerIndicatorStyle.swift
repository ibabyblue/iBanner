import SwiftUI

public enum IBannerIndicatorStyle {
    case dot(
        activeColor: Color = .white,
        inactiveColor: Color = .white.opacity(0.35),
        size: CGFloat = 8,
        spacing: CGFloat = 6
    )
    case capsule(
        activeColor: Color = .white,
        inactiveColor: Color = .white.opacity(0.35),
        dotSize: CGFloat = 8,
        expandedWidth: CGFloat = 22,
        spacing: CGFloat = 5
    )
}
