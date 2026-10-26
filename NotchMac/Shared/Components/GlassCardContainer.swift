//
//  GlassCardContainer.swift
//  NotchMac
//

import SwiftUI

/// Authentic MacBook liquid silhouette with concave top ears and convex bottom corners.
/// Fully animatable at 120fps during spring transitions.
struct NotchShape: Shape {
    var topCornerRadius: CGFloat
    var bottomCornerRadius: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(topCornerRadius, bottomCornerRadius) }
        set {
            topCornerRadius = newValue.first
            bottomCornerRadius = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        let topR = min(max(topCornerRadius, 0), rect.height / 2)
        let bottomR = min(max(bottomCornerRadius, 0), rect.height / 2)

        var path = Path()

        // Start at top-left outer ear tip
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))

        // Top-left concave ear curve curving down into the left vertical wall
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + topR, y: rect.minY + topR),
            control: CGPoint(x: rect.minX + topR, y: rect.minY)
        )

        // Left vertical wall down to bottom-left corner start
        path.addLine(to: CGPoint(x: rect.minX + topR, y: rect.maxY - bottomR))

        // Bottom-left convex corner curve
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + topR + bottomR, y: rect.maxY),
            control: CGPoint(x: rect.minX + topR, y: rect.maxY)
        )

        // Bottom horizontal edge
        path.addLine(to: CGPoint(x: rect.maxX - topR - bottomR, y: rect.maxY))

        // Bottom-right convex corner curve
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - topR, y: rect.maxY - bottomR),
            control: CGPoint(x: rect.maxX - topR, y: rect.maxY)
        )

        // Right vertical wall up to top-right ear start
        path.addLine(to: CGPoint(x: rect.maxX - topR, y: rect.minY + topR))

        // Top-right concave ear curve curving out to the top-right outer ear tip
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.maxX - topR, y: rect.minY)
        )

        path.closeSubpath()
        return path
    }
}

/// Reusable dark glassmorphic card container with a subtle hairline border for Notch widgets.
struct GlassCardContainer<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: NotchTheme.cardCornerRadius, style: .continuous)
                    .fill(NotchTheme.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: NotchTheme.cardCornerRadius, style: .continuous)
                    .strokeBorder(NotchTheme.cardBorder, lineWidth: NotchTheme.borderWidth)
            )
    }
}
