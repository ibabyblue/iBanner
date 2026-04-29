import SwiftUI
import iBanner

// MARK: - Demo Data Model

struct BannerCard: Identifiable {
    let id: Int
    let gradient: LinearGradient
    let title: String
    let subtitle: String
}

let sampleCards: [BannerCard] = [
    BannerCard(
        id: 0,
        gradient: LinearGradient(
            colors: [Color(red: 0.24, green: 0.48, blue: 0.99), Color(red: 0.05, green: 0.83, blue: 1)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        ),
        title: "春日特惠",
        subtitle: "全场满 200 减 50"
    ),
    BannerCard(
        id: 1,
        gradient: LinearGradient(
            colors: [Color(red: 0.97, green: 0.59, blue: 0.12), Color(red: 1, green: 0.84, blue: 0)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        ),
        title: "新品上市",
        subtitle: "限时 8 折优惠"
    ),
    BannerCard(
        id: 2,
        gradient: LinearGradient(
            colors: [Color(red: 0.58, green: 0.18, blue: 0.95), Color(red: 0.96, green: 0.41, blue: 0.7)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        ),
        title: "会员专享",
        subtitle: "积分双倍奖励"
    ),
    BannerCard(
        id: 3,
        gradient: LinearGradient(
            colors: [Color(red: 0.07, green: 0.6, blue: 0.43), Color(red: 0.22, green: 0.9, blue: 0.68)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        ),
        title: "限时抢购",
        subtitle: "仅剩最后 3 件"
    ),
]

// MARK: - Reusable Card View

struct GradientCardView: View {
    let card: BannerCard
    var cornerRadius: CGFloat = 0

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            card.gradient

            LinearGradient(
                colors: [.clear, .black.opacity(0.5)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(card.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                Text(card.subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
