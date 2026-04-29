import CoreGraphics

enum _BannerIndexCalculator {

    static func leftIndex(current: Int, count: Int) -> Int {
        (current - 1 + count) % count
    }

    static func rightIndex(current: Int, count: Int) -> Int {
        (current + 1) % count
    }

    /// 根据 contentOffset.x 和 pageWidth 判断滑动方向，返回新 index
    static func updatedIndex(
        currentIndex: Int,
        contentOffsetX: CGFloat,
        pageWidth: CGFloat,
        count: Int
    ) -> Int {
        if contentOffsetX < pageWidth {
            return leftIndex(current: currentIndex, count: count)
        } else if contentOffsetX > pageWidth {
            return rightIndex(current: currentIndex, count: count)
        }
        return currentIndex
    }
}
