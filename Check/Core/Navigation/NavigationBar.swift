//
//  NavigationBar.swift
//  Check
//
//  Created by Jajwol Bajracharya on 19/12/2024.
//

import SwiftUI

struct NavigationBar: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode

    var title: String
    var pendingListsCount: Int
    @Binding var showSignInView: Bool
    @Binding var isAdding: Bool
    @Binding var openPendingLists: Bool

    var body: some View {
        ZStack {
            Color(.surfaceDark).ignoresSafeArea()
            HStack {

                HStack(spacing: Padding.large) {
                    NavigationLink(
                        destination: SettingsView(showSignInView: $showSignInView)
                    ) {
                        Image(systemName: "ellipsis").foregroundStyle(Color.white)
                    }
                    Text(title)
                        .font(.title3.weight(.bold))

                }.frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: Padding.regular) {
                    Button(action: {
                        openPendingLists = true
                    }) {
                        pendingListsCount != 0
                            ? Image(systemName: "bell.badge")
                            : Image(systemName: "bell")
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
