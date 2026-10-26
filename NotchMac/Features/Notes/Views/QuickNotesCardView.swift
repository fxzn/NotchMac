//
//  QuickNotesCardView.swift
//  NotchMac
//

import SwiftUI

/// Clean, cardless interactive Horizon Timeline & Quick Memo widget (distinct from NotchNook while staying ultra-clean).
struct QuickNotesCardView: View {
    @ObservedObject var viewModel: QuickNotesViewModel

    private struct CalendarDayItem: Identifiable {
        let id: String
        let date: Date
        let dayLabel: String
        let dateNumber: String
        let isToday: Bool
        let isSelected: Bool
        let hasMemo: Bool
    }

    private var selectedHeaderText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM"
        return formatter.string(from: viewModel.selectedDate)
    }

    private var selectedDatePrompt: String {
        if Calendar.current.isDateInToday(viewModel.selectedDate) {
            return "Write a quick note for today..."
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return "Note for \(formatter.string(from: viewModel.selectedDate))..."
    }

    private var weekDays: [CalendarDayItem] {
        let calendar = Calendar.current
        let anchorToday = Date()
        guard let shiftedCenter = calendar.date(byAdding: .day, value: viewModel.weekOffset * 7, to: anchorToday) else {
            return []
        }

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        let numberFormatter = DateFormatter()
        numberFormatter.dateFormat = "d"
        let idFormatter = DateFormatter()
        idFormatter.dateFormat = "yyyy-MM-dd"

        return (-3...3).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: shiftedCenter) else {
                return nil
            }
            let isToday = calendar.isDateInToday(date)
            let isSelected = calendar.isDate(date, inSameDayAs: viewModel.selectedDate)
            let rawDay = dayFormatter.string(from: date).uppercased()
            let shortLabel = String(rawDay.prefix(1))

            return CalendarDayItem(
                id: idFormatter.string(from: date),
                date: date,
                dayLabel: shortLabel,
                dateNumber: numberFormatter.string(from: date),
                isToday: isToday,
                isSelected: isSelected,
                hasMemo: viewModel.hasNote(on: date)
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Top Row: Selected Date Header + Subtle Week Chevrons (left-aligned editorial style, distinct from NotchNook)
            HStack(spacing: 6) {
                Button {
                    withAnimation(NotchTheme.springAnimation) {
                        viewModel.jumpToToday()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedHeaderText)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.90))

                        if !Calendar.current.isDateInToday(viewModel.selectedDate) || viewModel.weekOffset != 0 {
                            Text("• Today")
                                .font(.system(size: 9.5, weight: .medium))
                                .foregroundStyle(NotchTheme.calendarAccent)
                        }
                    }
                }
                .buttonStyle(.plain)
                .help("Return to Today")

                Spacer(minLength: 0)

                HStack(spacing: 8) {
                    Button {
                        withAnimation(NotchTheme.springAnimation) {
                            viewModel.shiftWeek(by: -1)
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 8.5, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.40))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Button {
                        withAnimation(NotchTheme.springAnimation) {
                            viewModel.shiftWeek(by: 1)
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 8.5, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.40))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }

            // Middle Row: Clean 7-Day Interactive Timeline with soft circular highlight on active day
            HStack(spacing: 4) {
                ForEach(weekDays) { item in
                    Button {
                        withAnimation(NotchTheme.springAnimation) {
                            viewModel.selectDate(item.date)
                        }
                    } label: {
                        VStack(spacing: 2) {
                            Text(item.dayLabel)
                                .font(.system(size: 7.5, weight: .medium))
                                .foregroundStyle(
                                    item.isSelected
                                        ? .white.opacity(0.90)
                                        : .white.opacity(0.35)
                                )

                            ZStack {
                                if item.isSelected {
                                    Circle()
                                        .fill(Color.white.opacity(0.16))
                                        .frame(width: 21, height: 21)
                                }

                                Text(item.dateNumber)
                                    .font(.system(size: 11, weight: item.isSelected ? .bold : .medium))
                                    .foregroundStyle(
                                        item.isSelected
                                            ? .white
                                            : (item.isToday ? NotchTheme.calendarAccent : .white.opacity(0.50))
                                    )
                            }
                            .frame(width: 21, height: 21)

                            Circle()
                                .fill(
                                    item.hasMemo
                                        ? NotchTheme.calendarAccent
                                        : .clear
                                )
                                .frame(width: 3, height: 3)
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 12)
                    .onEnded { value in
                        if value.translation.width < -18 {
                            withAnimation(NotchTheme.springAnimation) {
                                viewModel.shiftWeek(by: 1)
                            }
                        } else if value.translation.width > 18 {
                            withAnimation(NotchTheme.springAnimation) {
                                viewModel.shiftWeek(by: -1)
                            }
                        }
                    }
            )

            // Bottom Row: Minimalist left-aligned inline note line (no boxy container, distinct from NotchNook's centered icon)
            HStack(spacing: 6) {
                Image(systemName: viewModel.noteText.isEmpty ? "pencil.line" : "checkmark.circle.fill")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(
                        viewModel.noteText.isEmpty
                            ? .white.opacity(0.35)
                            : NotchTheme.calendarAccent
                    )

                TextField(
                    "",
                    text: $viewModel.noteText,
                    prompt: Text(selectedDatePrompt)
                        .foregroundStyle(.white.opacity(0.35))
                )
                .textFieldStyle(.plain)
                .font(.system(size: 10.5, weight: .regular))
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(1)

                if !viewModel.noteText.isEmpty {
                    Button(action: viewModel.clearNote) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 9.5))
                            .foregroundStyle(.white.opacity(0.35))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
