//
//  NotchTheme.swift
//  NotchMac
//

import SwiftUI

/// Centralized design tokens for NotchMac's clean, pure-black native macOS aesthetic.
enum NotchTheme {
    // MARK: - Animation Physics
    /// Strictly mandated Apple Spring Physics (response: 0.35, dampingFraction: 0.75, blendDuration: 0)
    static let springAnimation = Animation.spring(
        response: 0.35,
        dampingFraction: 0.75,
        blendDuration: 0
    )

    // MARK: - Corner Radii
    static let collapsedCornerRadius: CGFloat = 10
    static let expandedCornerRadius: CGFloat = 20
    static let cardCornerRadius: CGFloat = 12

    // MARK: - Dimensions & Spacing
    static let contentPadding: CGFloat = 14
    static let cardSpacing: CGFloat = 14
    static let borderWidth: CGFloat = 0.5

    // MARK: - Colors
    static let notchBackground = Color.black

    static let cardFill = Color.white.opacity(0.05)
    static let cardBorder = Color.white.opacity(0.08)

    // MARK: - Subtle Native Accents
    static let spotifyAccent = Color(red: 0.12, green: 0.84, blue: 0.38)
    static let appleMusicAccent = Color(red: 0.98, green: 0.22, blue: 0.34)
    static let youtubeAccent = Color(red: 1.00, green: 0.00, blue: 0.20)
    static let netflixAccent = Color(red: 0.90, green: 0.04, blue: 0.08)
    static let browserAccent = Color(red: 0.22, green: 0.58, blue: 1.00)

    /// Clean macOS system blue for active calendar date
    static let calendarAccent = Color(red: 0.24, green: 0.56, blue: 1.00)
    static let notesAccent = Color.white.opacity(0.75)
}
