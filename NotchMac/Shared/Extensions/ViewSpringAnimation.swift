//
//  ViewSpringAnimation.swift
//  NotchMac
//

import SwiftUI

extension View {
    /// Applies the standard NotchMac Apple Spring Physics animation (`response: 0.35, dampingFraction: 0.75, blendDuration: 0`).
    func notchSpringAnimation<V: Equatable>(value: V) -> some View {
        animation(NotchTheme.springAnimation, value: value)
    }
}
