//
//  NotchNavigationState.swift
//  NotchMac
//

import Combine
import SwiftUI

/// Represents the active tab inside the expanded notch.
enum NotchTab: String, CaseIterable, Identifiable, Sendable {
    case nook = "Nook"
    case tray = "Tray"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .nook:
            return "sparkles.rectangle.stack.fill"
        case .tray:
            return "tray.and.arrow.down.fill"
        }
    }
}

/// Manages the expanded/collapsed state and active tab of the notch companion.
@MainActor
final class NotchNavigationState: ObservableObject {
    @Published var isExpanded: Bool = false
    @Published var activeTab: NotchTab = .nook
    @Published var geometry: NotchGeometry = .current()

    func setExpanded(_ expanded: Bool) {
        guard isExpanded != expanded else { return }
        withAnimation(NotchTheme.springAnimation) {
            isExpanded = expanded
        }
    }

    func refreshGeometry(for screen: NSScreen? = NSScreen.notchScreen) {
        geometry = .current(for: screen)
    }
}
