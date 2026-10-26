//
//  NotchGeometry.swift
//  NotchMac
//

import AppKit
import CoreGraphics

/// Pixel-perfect calculation of the physical hardware notch and panel frames using NSScreen auxiliary areas.
struct NotchGeometry: Sendable, Equatable {
    let notchWidth: CGFloat
    let notchHeight: CGFloat
    let screenFrame: CGRect
    let hasPhysicalNotch: Bool

    /// Expanded dimensions when user hovers over the notch
    static let expandedWidth: CGFloat = 500
    static let expandedHeight: CGFloat = 210

    /// Extra padding around the panel canvas to accommodate spring overshoot and shadow/glow
    static let canvasHorizontalPadding: CGFloat = 40
    static let canvasVerticalPadding: CGFloat = 30

    /// Fallback dimensions for external monitors or Macs without a physical camera housing
    private static let fallbackNotchWidth: CGFloat = 184
    private static let fallbackNotchHeight: CGFloat = 32

    /// Dynamically computes the notch geometry for a given screen (defaults to the main/built-in screen).
    static func current(for screen: NSScreen? = NSScreen.notchScreen) -> NotchGeometry {
        guard let screen else {
            return NotchGeometry(
                notchWidth: fallbackNotchWidth,
                notchHeight: fallbackNotchHeight,
                screenFrame: .zero,
                hasPhysicalNotch: false
            )
        }

        let leftAreaWidth = screen.auxiliaryTopLeftArea?.width ?? 0
        let rightAreaWidth = screen.auxiliaryTopRightArea?.width ?? 0
        let dynamicNotchWidth = screen.frame.width - leftAreaWidth - rightAreaWidth
        let dynamicNotchHeight = screen.safeAreaInsets.top

        let hasNotch = dynamicNotchHeight > 0 && leftAreaWidth > 0 && rightAreaWidth > 0

        let resolvedWidth = hasNotch ? max(dynamicNotchWidth, 160) : fallbackNotchWidth
        let resolvedHeight = hasNotch ? dynamicNotchHeight : max(NSStatusBar.system.thickness, fallbackNotchHeight)

        return NotchGeometry(
            notchWidth: resolvedWidth,
            notchHeight: resolvedHeight,
            screenFrame: screen.frame,
            hasPhysicalNotch: hasNotch
        )
    }

    /// Static bounding box frame for the NSPanel anchored to the top-center of the screen.
    /// Keeping a static panel bounding box avoids resizing NSWindow every animation frame.
    var panelFrame: CGRect {
        let width = Self.expandedWidth + Self.canvasHorizontalPadding
        let height = Self.expandedHeight + Self.canvasVerticalPadding
        let originX = screenFrame.midX - (width / 2)
        let originY = screenFrame.maxY - height
        return CGRect(x: originX.rounded(), y: originY.rounded(), width: width, height: height)
    }
}
