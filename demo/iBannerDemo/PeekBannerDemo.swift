import SwiftUI

struct PeekBannerDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {

                // ── 无限 Peek ──────────────────────────────────────────
                SectionHeader(
                    title: "无限 Peek",
                    subtitle: "UICollectionView 虚拟 section，支持连续快速滑动"
                )

                // 1. 标准无限 Peek（两侧各露出 30pt）
                PeekLabel(text: "标准 Peek · 30pt inset")
                InfinitePeekBannerView(
                    items: sampleCards,
                    peekInset: 30,
                    itemSpacing: 12
                ) { card in
                    GradientCardView(card: card, cornerRadius: 14)
                        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                }
                .frame(height: 180)

                // 2. 大 Peek（两侧各露出 50pt）
                PeekLabel(text: "大 Peek · 50pt inset")
                InfinitePeekBannerView(
                    items: sampleCards,
                    peekInset: 50,
                    itemSpacing: 16
                ) { card in
                    GradientCardView(card: card, cornerRadius: 18)
                        .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
                }
                .frame(height: 160)

                Divider().padding(.horizontal)

                // ── 有限 Peek（原生 ScrollView）──────────────────────────
                SectionHeader(
                    title: "有限 Peek（原生 ScrollView）",
                    subtitle: "iOS 17 viewAligned + containerRelativeFrame，item 固定数量"
                )

                // 3. 标准 Peek
                PeekLabel(text: "标准 Peek · 两侧各露出 ~30pt")
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

                // 4. 大 Peek
                PeekLabel(text: "大 Peek · card 宽 75%")
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

                // 5. 高卡片 Peek
                PeekLabel(text: "高卡片 Peek · card 宽 80%")
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
            .padding(.vertical, 16)
        }
        .navigationTitle("Peek Banner")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Private helpers

private struct SectionHeader: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
    }
}

private struct PeekLabel: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .padding(.horizontal)
    }
}
