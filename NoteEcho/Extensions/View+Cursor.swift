import SwiftUI

extension View {
    /// Adds a pointing hand cursor when hovering over the view on macOS
    func pointingHandCursor() -> some View {
        if #available(macOS 13.0, *) {
            return self.onContinuousHover { phase in
                switch phase {
                case .active(_): 
                    NSCursor.pointingHand.push()
                case .ended: 
                    NSCursor.pop()
                }
            }
        } else {
            return self.onHover { inside in
                if inside {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }
}