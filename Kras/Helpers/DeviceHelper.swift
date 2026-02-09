import SwiftUI

struct DeviceHelper {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    static var maxContentWidth: CGFloat {
        isIPad ? 700 : .infinity
    }
    
    static var horizontalPadding: CGFloat {
        isIPad ? 40 : 16
    }
    
    static var gridColumns: Int {
        isIPad ? 3 : 2
    }
    
    static var listGridColumns: Int {
        isIPad ? 2 : 1
    }
}

struct AdaptiveContainer<Content: View>: View {
    let content: Content
    var maxWidth: CGFloat
    
    init(maxWidth: CGFloat = DeviceHelper.maxContentWidth, @ViewBuilder content: () -> Content) {
        self.maxWidth = maxWidth
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                content
                    .frame(maxWidth: maxWidth)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct AdaptiveHStack<Content: View>: View {
    let content: Content
    var spacing: CGFloat
    
    init(spacing: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        if DeviceHelper.isIPad {
            HStack(alignment: .top, spacing: spacing) {
                content
            }
        } else {
            VStack(spacing: spacing) {
                content
            }
        }
    }
}

extension View {
    func adaptivePadding() -> some View {
        self.padding(.horizontal, DeviceHelper.horizontalPadding)
    }
    
    func limitWidth(_ maxWidth: CGFloat = DeviceHelper.maxContentWidth) -> some View {
        self.frame(maxWidth: maxWidth)
    }
}

