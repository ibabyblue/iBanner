import SwiftUI

public struct DemoRootView: View {
    public init() {}

    public var body: some View {
        TabView {
            NavigationStack {
                FullScreenBannerDemo()
            }
            .tabItem {
                Label("全屏", systemImage: "rectangle.fill")
            }

            NavigationStack {
                PeekBannerDemo()
            }
            .tabItem {
                Label("Peek", systemImage: "rectangle.split.3x1.fill")
            }
        }
    }
}

#Preview {
    DemoRootView()
}
