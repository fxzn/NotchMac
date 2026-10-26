//
//  NotchGeometry.swift
//  NotchMac
//

import AppKit

/// Computes and stores the exact screen coordinates for the collapsed hardware notch and expanded NotchMac overlay.
nonisolated struct NotchGeometry: Equatable, Sendable {
    let notchWidth: CGFloat
    let notchHeight: CGFloat
    let screenFrame: CGRect

    /// Top concave ear radius in collapsed state
    static let collapsedTopEarRadius: CGFloat = 6
    /// Top concave ear radius in expanded state
    static let expandedTopEarRadius: CGFloat = 13

    /// Clean, sleek proportions with enough room so nothing clips
    static let expandedWidth: CGFloat = 456
    static let expandedHeight: CGFloat = 136

    /// Extra margin around the expanded notch to accommodate top concave ears and drop shadow
    private static let shadowMarginX: CGFloat = 28
    private static let shadowMarginBottom: CGFloat = 24

    /// Static bounding frame for the floating NSPanel so we never animate NSWindow.setFrame on every tick.
    var panelFrame: CGRect {
        let totalWidth = Self.expandedWidth + (Self.expandedTopEarRadius * 2) + (Self.shadowMarginX * 2)
        let totalHeight = Self.expandedHeight + Self.shadowMarginBottom
        let originX = screenFrame.origin.x + ((screenFrame.width - totalWidth) / 2.0)
        let originY = screenFrame.maxY - totalHeight

        return CGRect(
            x: originX.rounded(),
            y: originY.rounded(),
            width: totalWidth.rounded(),
            height: totalHeight.rounded()
        )
    }

    /// Calculates the current geometry from the target screen using auxiliaryTopLeftArea and auxiliaryTopRightArea.
    @MainActor
    static func current(for screen: NSScreen? = nil) -> NotchGeometry {
        guard let targetScreen = screen ?? NSScreen.notchScreen else {
            return NotchGeometry(
                notchWidth: 184,
                notchHeight: 32,
                screenFrame: CGRect(x: 0, y: 0, width: 1440, height: 900)
            )
        }

        let frame = targetScreen.frame
        let safeTop = targetScreen.safeAreaInsets.top

        if safeTop > 0,
           let leftArea = targetScreen.auxiliaryTopLeftArea,
           let rightArea = targetScreen.auxiliaryTopRightArea {
            let cutWidth = max(160, rightArea.minX - leftArea.maxX)
            let cutHeight = max(28, safeTop)
            return NotchGeometry(
                notchWidth: cutWidth,
                notchHeight: cutHeight,
                screenFrame: frame
            )
        }

        let menuBarHeight = max(28, frame.maxY - targetScreen.visibleFrame.maxY)
        return NotchGeometry(
            notchWidth: 184,
            notchHeight: menuBarHeight,
            screenFrame: frame
        )
    }
}
