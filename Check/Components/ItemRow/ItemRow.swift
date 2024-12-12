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
        HStack {
            Text(item.name)
                .strikethrough(isComplete)
                .foregroundColor(isComplete ? .gray : .primary)
            Spacer()
            Button(action: {
                toggleItemCompletion(item)
            }) {
                Image(systemName: isComplete ? "circle.fill" : "circle")
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
