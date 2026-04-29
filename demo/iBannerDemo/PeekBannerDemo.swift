import SwiftUI

// Peek 效果使用 iOS 17 原生 ScrollView API 实现。
// iBanner 的三页虚拟复用方案让 ScrollView 与容器等宽，天然不支持露出相邻 item。
// 两者定位互补：iBanner 做全屏广告 Banner，原生 ScrollView 做卡片 Peek 列表。

struct PeekBannerDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {

                // 1. 标准 Peek：两侧各露出约 30pt
                PeekSection(
                    title: "标准 Peek",
                    subtitle: "card 宽 = 屏宽 - 60，两侧各露出 ~30pt"
                ) {
                    ScrollView(.horizontal) {
                        HStack(spacing: 12) {
                            ForEach(sampleCards) { card in
                                GradientCardView(card: card, cornerRadius: 14)
                                    .containerRelativeFrame(.horizontal) { w, _ in w - 60 }
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

                // 2. 大 Peek：card 宽 75%，相邻露出更多
                PeekSection(
                    title: "大 Peek",
                    subtitle: "card 宽 75% 屏宽，视觉层次感更强"
                ) {
                    ScrollView(.horizontal) {
                        HStack(spacing: 16) {
                            ForEach(sampleCards) { card in
                                GradientCardView(card: card, cornerRadius: 18)
                                    .containerRelativeFrame(.horizontal) { w, _ in w * 0.75 }
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

                // 3. 竖向高卡片 Peek
                PeekSection(
                    title: "高卡片 Peek",
                    subtitle: "card 宽 80%，适合内容丰富的卡片场景"
                ) {
                    ScrollView(.horizontal) {
                        HStack(spacing: 14) {
                            ForEach(sampleCards) { card in
                                GradientCardView(card: card, cornerRadius: 20)
                                    .containerRelativeFrame(.horizontal) { w, _ in w * 0.8 }
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

private struct PeekSection<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.horizontal)
            content()
        }
    }
}
