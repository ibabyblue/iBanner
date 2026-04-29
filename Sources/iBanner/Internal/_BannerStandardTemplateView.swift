import SwiftUI

struct _BannerStandardTemplateView<Item: BannerDisplayable>: View {
    let item: Item

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                imageLayer(size: geo.size)

                if item.title != nil || item.subtitle != nil {
                    // 渐变遮罩
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.6)],
                        startPoint: .center,
                        endPoint: .bottom
                    )

                    textLayer
                }
            }
        }
    }

    @ViewBuilder
    private func imageLayer(size: CGSize) -> some View {
        if let url = item.imageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.width, height: size.height)
                        .clipped()
                case .failure, .empty:
                    Color.gray.opacity(0.3)
                @unknown default:
                    Color.gray.opacity(0.3)
                }
            }
        } else {
            Color.gray.opacity(0.3)
        }
    }

    private var textLayer: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let title = item.title {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
            if let subtitle = item.subtitle {
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.bottom, 14)
    }
}
