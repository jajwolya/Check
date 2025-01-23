//
//  ConfirmSheet.swift
//  Check
//
//  Created by Jajwol Bajracharya on 11/1/2025.
//

import SwiftUI

struct ConfirmSheet: View {
    let heading: String
    let text: String
    var caption: String?
    let dismissAction: () -> Void
    let confirmAction: () async throws -> Void

    var body: some View {
        VStack(spacing: Padding.medium) {
            Text(heading)
                .font(.title3).fontWeight(.semibold).foregroundStyle(Color.light)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            
            if let caption = caption {
                Text(caption)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
                
            Spacer()
            HStack(spacing: Padding.regular) {
                Button(action: dismissAction) {
                    Text("No")
                        .foregroundStyle(Color.light)
                        .fontWeight(.medium)
                        .padding(Padding.regular)
                        .frame(
                            maxWidth: .infinity, alignment: .center
                        )
                        .background(
                            RoundedRectangle(
                                cornerRadius: CornerRadius.medium
                            )
                            .fill(
                                Color.surface)
                        )
                }
                Button(action: {
                    Task {
                        do {
                            try await confirmAction()
                        } catch {
                            print(
                                "Error deleting list: \(error.localizedDescription)"
                            )
                        }
                    }
                }) {
                    Text("Yes")
                        .foregroundStyle(Color.light)
                        .fontWeight(.medium)
                        .padding(Padding.regular)
                        .frame(
                            maxWidth: .infinity, alignment: .center
                        )
                        .background(
                            RoundedRectangle(
                                cornerRadius: CornerRadius.medium
                            )
                            .fill(
                                Color.surface)
                        )
                }
            }
        }
        .presentationDetents([.fraction(0.5)])
        .presentationBackground(.ultraThinMaterial)
        .sheetPadding()
    }
}
