//
//  SignInNavBar.swift
//  Check
//
//  Created by Jajwol Bajracharya on 28/12/2024.
//

import SwiftUI

struct SignInNavBar: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    var title: String

    var body: some View {
        ZStack {
            Color(.surfaceBackground).ignoresSafeArea()
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
            }.foregroundStyle(Color.content).padding(.horizontal, Padding.gutter)
        }
        .frame(height: 64)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

//#Preview {
//    NavigationBar(title: "Title")
//}
