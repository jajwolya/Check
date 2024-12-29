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
    @Binding var listName: String
    @Binding var openPendingLists: Bool
    @Binding var isEditingList: Bool

    var body: some View {
        ZStack {
            Color(.surfaceBackground).ignoresSafeArea()
            HStack {
                HStack(spacing: Padding.large) {
                    NavigationLink(
                        destination: SettingsView(showSignInView: $showSignInView)
                    ) {
                        Image(systemName: "gearshape").foregroundStyle(Color.white)
                    }
                    Text(title)
                        .font(.title2.weight(.bold))
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
                        isEditingList = false
                        listName = ""
                    }) {
                        Image(systemName: "plus")
                    }
                    .frame(width: 32, height: 32, alignment: .center)
                    .background(Circle().fill(Color.surface))
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
