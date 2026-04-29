import SwiftUI
import iBanner

struct FullScreenBannerDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {

                // 1. 自定义 View + Dot 指示器（默认自动播放 3s）
                DemoSection(title: "自定义 View · Dot 指示器") {
                    BannerView(items: sampleCards) { card in
                        GradientCardView(card: card)
                    }
                    .bannerIndicator(.dot())
                    .bannerAutoPlay(interval: 3)
                    .frame(height: 200)
                }

                // 2. 自定义 View + Capsule 指示器（跟手动画）
                DemoSection(title: "自定义 View · Capsule 指示器") {
                    BannerView(items: sampleCards) { card in
                        GradientCardView(card: card)
                    }
                    .bannerIndicator(.capsule())
                    .bannerAutoPlay(interval: 3)
                    .frame(height: 200)
                }

                // 3. 自定义数字指示器 + 翻页回调
                DemoSection(title: "自定义指示器 · 数字 + 回调") {
                    BannerView(items: sampleCards) { card in
                        GradientCardView(card: card)
                    } indicator: { index, total in
                        Text("\(index + 1) / \(total)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.black.opacity(0.4), in: Capsule())
                    }
                    .bannerAutoPlay(interval: 3)
                    .onBannerPageChanged { index, card in
                        print("[iBannerDemo] page: \(index) — \(card.title)")
                    }
                    .frame(height: 200)
                }

                // 4. 禁用自动播放，自定义颜色
                DemoSection(title: "禁用自动播放 · 手动滑动") {
                    BannerView(items: sampleCards) { card in
                        GradientCardView(card: card)
                    }
                    .bannerIndicator(.dot(activeColor: .yellow, inactiveColor: .white.opacity(0.4)))
                    .bannerAutoPlay(interval: nil)
                    .frame(height: 200)
                }

            }
            .padding(.vertical, 16)
        }
        .navigationTitle("全屏 Banner")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct DemoSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            content()
        }
    }
}
