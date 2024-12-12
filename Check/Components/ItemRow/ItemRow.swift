//
//  ItemRow.swift
//  Check
//
//  Created by Jajwol Bajracharya on 12/12/2024.
//

import SwiftUI

struct ItemRow: View {
    @Environment(\.modelContext) private var context
    let item: Item
    let isComplete: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            HStack {
                Text(item.name)
                    .strikethrough(isComplete)
                    .foregroundColor(isComplete ? .gray : .primary)
                Spacer()
                Text("(\(item.quantity))").strikethrough(isComplete)
                    .foregroundColor(isComplete ? .gray : .primary)
                Button(action: {
                    toggleItemCompletion(item)
                }) {
                    Image(systemName: isComplete ? "circle.fill" : "circle")
                }
            }
            if !item.note.isEmpty && !isComplete {
                Text(item.note)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func toggleItemCompletion(_ item: Item) {
        withAnimation {
            item.isComplete.toggle()
            do {
                try context.save()
            } catch {
                print("Failed to toggle item completion: \(error)")
            }
        }
    }
}
