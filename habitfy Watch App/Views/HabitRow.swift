//
//  HabitRow.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 16/02/2025.
//

import Foundation
import SwiftUI

struct HabitRow: View {
    let habit: Habit
    let isCompleted: Bool
    
    /// Called when the user taps the row to complete the habit.
    let onComplete: () -> Void
    
    /// Called when the user swipes to delete the habit.
    let onDelete: () -> Void
    
    /// Called when the user swipes to undo today’s completion.
    let onUndo: () -> Void

    var body: some View {
        Button {
            // If not completed, tapping completes the habit
            if !isCompleted {
                onComplete()
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .foregroundColor(isCompleted ? .gray : .primary)

                    Text("🔥 \(habit.streak) \(habit.streak == 1 ? "day" : "days")")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding(.vertical, 4)
        }
        .listRowBackground(
            isCompleted
            ? Color.green.opacity(0.2)
            : Color.gray.opacity(0.2)
        )
        // Swipe Left: Delete
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        // Swipe Right: Undo
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            if isCompleted {
                Button {
                    onUndo()
                } label: {
                    Label("Undo", systemImage: "arrow.uturn.left.circle")
                }
                .tint(.blue)
            }
        }
    }
}
