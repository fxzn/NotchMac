//
//  NotchNavigationState.swift
//  NotchMac
//

import Combine
import Foundation

/// Represents the active workspace mode inside the expanded NotchMac interface.
enum NotchTab: String, CaseIterable, Identifiable, Sendable {
    case nook = "Live"
    case tray = "Stash"

    var id: String { rawValue }
}

/// Centralized navigation and expansion state for the Notch container.
@MainActor
final class NotchNavigationState: ObservableObject {
    @Published var isExpanded: Bool = false
    @Published var isPinned: Bool = false
    @Published var activeTab: NotchTab = .nook
    @Published var geometry: NotchGeometry

    init(geometry: NotchGeometry? = nil) {
        self.geometry = geometry ?? NotchGeometry.current()
    }

    func setExpanded(_ expanded: Bool) {
        if !expanded && isPinned {
            return
        }
        guard isExpanded != expanded else { return }
        isExpanded = expanded
    }

    func togglePin() {
        isPinned.toggle()
        if isPinned {
            isExpanded = true
        }
    }
}
