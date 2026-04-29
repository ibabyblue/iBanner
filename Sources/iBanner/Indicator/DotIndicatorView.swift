import SwiftUI

struct DotIndicatorView: View {
    let currentIndex: Int
    let total: Int
    var activeColor: Color = .white
    var inactiveColor: Color = .white.opacity(0.35)
    var size: CGFloat = 8
    var spacing: CGFloat = 6

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? activeColor : inactiveColor)
                    .frame(width: size, height: size)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: currentIndex)
    }
}
