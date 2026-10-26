//
//  NotchTheme.swift
//  NotchMac
//

import SwiftUI

/// Centralized design tokens, colors, corner radii, and Apple spring physics constants.
enum NotchTheme {
    // MARK: - Animations

    /// Standard Apple Spring Physics animation required for all notch state transitions (120fps ProMotion fluid feel).
    static let springAnimation: Animation = .spring(
        response: 0.35,
        dampingFraction: 0.75,
        blendDuration: 0
    )

    // MARK: - Colors

    /// Pure OLED black matching the physical MacBook notch housing.
    static let notchBackground = Color.black

    /// Subtle dark elevated surface for inner widget cards.
    static let cardBackground = Color.white.opacity(0.07)

    /// Hairline border stroke for the expanded notch and inner glass cards.
    static let hairlineBorder = Color.white.opacity(0.12)

    /// Primary accent color for active indicators (Spotify green).
    static let spotifyAccent = Color(red: 0.11, green: 0.73, blue: 0.33)

    /// Warm accent color for Quick Notes.
    static let notesAccent = Color(red: 1.0, green: 0.80, blue: 0.28)

    // MARK: - Dimensions & Corner Radii

    static let collapsedCornerRadius: CGFloat = 14
    static let expandedCornerRadius: CGFloat = 24
    static let cardCornerRadius: CGFloat = 14
    static let borderWidth: CGFloat = 0.8
}
