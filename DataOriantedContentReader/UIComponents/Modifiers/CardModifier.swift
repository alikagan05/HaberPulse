// CardModifier.swift
// DataOriantedContentReader
// UIComponents → Modifiers

import SwiftUI

/// Kart tasarımı için tekrar kullanılabilir ViewModifier.
struct CardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var shadowRadius: CGFloat = 8
    var shadowOpacity: Double = 0.07

    func body(content: Content) -> some View {
        content
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(
                color: Color.primary.opacity(shadowOpacity),
                radius: shadowRadius,
                x: 0,
                y: 3
            )
    }
}

extension View {
    func cardStyle(
        cornerRadius: CGFloat = 16,
        shadowRadius: CGFloat = 8,
        shadowOpacity: Double = 0.07
    ) -> some View {
        modifier(CardModifier(
            cornerRadius: cornerRadius,
            shadowRadius: shadowRadius,
            shadowOpacity: shadowOpacity
        ))
    }
}
