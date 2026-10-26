//
//  NSScreenNotch.swift
//  NotchMac
//

import AppKit

extension NSScreen {
    /// Returns the preferred screen for hosting the notch panel (prioritizes screens with a physical notch, then main screen).
    static var notchScreen: NSScreen? {
        if let screenWithNotch = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) {
            return screenWithNotch
        }
        return NSScreen.main ?? NSScreen.screens.first
    }

    /// Indicates whether this display has a physical camera housing notch.
    var hasPhysicalNotch: Bool {
        safeAreaInsets.top > 0 && auxiliaryTopLeftArea != nil && auxiliaryTopRightArea != nil
    }
}
