//
//  GlassCardContainer.swift
//  NotchMac
//

import SwiftUI

/// Reusable dark glassmorphic card container with a subtle hairline border for Notch widgets.
struct GlassCardContainer<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: NotchTheme.cardCornerRadius, style: .continuous)
                    .fill(NotchTheme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: NotchTheme.cardCornerRadius, style: .continuous)
                    .strokeBorder(NotchTheme.hairlineBorder, lineWidth: NotchTheme.borderWidth)
            )
    }
}
