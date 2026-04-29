import SwiftUI

// Peek Banner 使用 iOS 17 原生 ScrollView API 实现，与 iBanner 全屏方案互补。
// iBanner 内核的 UIScrollView 三页复用不支持裁剪外区域可见，因此 peek 场景改用
// scrollTargetBehavior(.viewAligned) + containerRelativeFrame + contentMargins 实现。

struct PeekBannerDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {

                // 1. 标准 Peek：两侧各露出约 30pt
                PeekSection(
                    title: "标准 Peek · 两侧各 ~30pt",
                    subtitle: "card 宽度 = 屏宽 - 60，spacing = 12"
                ) {
                    ScrollView(.horizontal) {
                        HStack(spacing: 12) {
                            ForEach(sampleCards) { card in
                                GradientCardView(card: card, cornerRadius: 14)
                                    .containerRelativeFrame(.horizontal) { width, _ in
                                        width - 60
                                    }
                                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .contentMargins(.horizontal, 30, for: .scrollContent)
                    .scrollTargetBehavior(.viewAligned)
                    .scrollIndicators(.hidden)
                    .frame(height: 180)
                }

                // 2. 大 Peek：相邻 card 露出约 12.5% 屏宽
                PeekSection(
                    title: "大 Peek · card 宽度 75% 屏宽",
                    subtitle: "两侧各露出 ~12.5% 屏宽，视觉层次更强"
                ) {
                    ScrollView(.horizontal) {
                        HStack(spacing: 16) {
                            ForEach(sampleCards) { card in
                                GradientCardView(card: card, cornerRadius: 18)
                                    .containerRelativeFrame(.horizontal) { width, _ in
                                        width * 0.75
                                    }
                                    .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .contentMargins(.horizontal, 30, for: .scrollContent)
                    .scrollTargetBehavior(.viewAligned)
                    .scrollIndicators(.hidden)
                    .frame(height: 160)
                }

                // 3. 竖向卡片 Peek（适合内容列表场景）
                PeekSection(
                    title: "竖向卡片 Peek",
                    subtitle: "card 宽度 80% 屏宽，圆角更大"
                ) {
                    ScrollView(.horizontal) {
                        HStack(spacing: 14) {
                            ForEach(sampleCards) { card in
                                GradientCardView(card: card, cornerRadius: 20)
                                    .containerRelativeFrame(.horizontal) { width, _ in
                                        width * 0.8
                                    }
                                    .containerRelativeFrame(.vertical) { height, _ in
                                        height
                                    }
                                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .contentMargins(.horizontal, 24, for: .scrollContent)
                    .scrollTargetBehavior(.viewAligned)
                    .scrollIndicators(.hidden)
                    .frame(height: 220)
                }

            }
            .padding(.vertical, 16)
        }
        .navigationTitle("Peek Banner")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Helper

private struct PeekSection<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(Color.secondary.opacity(0.7))
                .padding(.horizontal)
            content()
        }
    }
}

#Preview {
    NavigationStack { PeekBannerDemo() }
}
