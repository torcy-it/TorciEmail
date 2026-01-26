import SwiftUI

struct ScrollEdgeTuning: ViewModifier {
    func body(content: Content) -> some View {
        content.scrollEdgeEffectStyle(.soft, for: .top)
    }
}
