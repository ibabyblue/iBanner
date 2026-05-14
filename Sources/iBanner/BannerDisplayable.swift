import Foundation

public protocol IBannerDisplayable: Identifiable {
    var imageURL: URL? { get }
    var title: String? { get }
    var subtitle: String? { get }
}
