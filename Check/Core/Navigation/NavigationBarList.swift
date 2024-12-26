//
//  NavigationBar.swift
//  Check
//
//  Created by Jajwol Bajracharya on 19/12/2024.
//

import SwiftUI

struct NavigationBarList: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode

    var title: String
    var displayShare: Bool = false
    @Binding var isAdding: Bool
    @Binding var isSharing: Bool

    var body: some View {
        ZStack {
            Color(.surfaceDark).ignoresSafeArea()
            HStack {

                HStack(spacing: Padding.large) {
                    if presentationMode.wrappedValue.isPresented {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.backward")

                        }
                    }
                    Text(title)
                        .font(.title3.weight(.bold))

                }.frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: Padding.regular) {
                    Button(action: {
                        isSharing = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    Button(action: {
                        isAdding = true
                    }) {
                        Image(systemName: "plus")
                    }
                }.frame(alignment: .trailing)

            }.foregroundStyle(Color.white).padding(.horizontal, Padding.gutter)
        }
        .frame(height: 64)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

//#Preview {
//    NavigationBar(title: "Title")
//}
