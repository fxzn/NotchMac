//
//  QuickNotesCardView.swift
//  NotchMac
//

import SwiftUI

/// Displays a quick scratchpad note widget inside the expanded Notch.
struct QuickNotesCardView: View {
    @ObservedObject var viewModel: QuickNotesViewModel

    var body: some View {
        GlassCardContainer {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "note.text")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(NotchTheme.notesAccent)

                    Text("QUICK NOTE")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                        .tracking(0.6)

                    Spacer()

                    if !viewModel.noteText.isEmpty {
                        Button(action: viewModel.clearNote) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        .buttonStyle(.plain)
                        .help("Clear note")
                    }
                }

                TextField(
                    "Jot something down...",
                    text: $viewModel.noteText,
                    axis: .vertical
                )
                .textFieldStyle(.plain)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(3...4)

                Spacer(minLength: 0)
            }
        }
    }
}
