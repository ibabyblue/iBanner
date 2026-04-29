import Foundation

public protocol BannerDisplayable: Identifiable {
    var imageURL: URL? { get }
    var title: String? { get }
    var subtitle: String? { get }
}
