//
//  NavigationBar.swift
//  Check
//
//  Created by Jajwol Bajracharya on 19/12/2024.
//

import SwiftUI

struct MainNavBar: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode

    var title: String
    var pendingListsCount: Int
    @Binding var showSignInView: Bool
    //    @Binding var activeSheet: ActiveSheet?
    @Binding var activeSheet: SheetType?
    //    @Binding var showPendingSheet: Bool

    var body: some View {
        ZStack {
            Color(.surfaceBackground).ignoresSafeArea()
            //            RadialGradient(
            //                colors: [Color.themeOnePrimary, Color.themeOneSecondary],
            //                center: .topLeading,
            //                startRadius: 96,
            //                endRadius: 420
            //            ).ignoresSafeArea()
            //            LinearGradient(
            //                colors: [Color.themeOnePrimary, Color.themeOneSecondary],
            //                startPoint: .top,
            //                endPoint: .bottom
            //            ).ignoresSafeArea()
            HStack {
                HStack(spacing: Padding.large) {
                    NavigationLink(
                        destination: SettingsView(
                            showSignInView: $showSignInView)
                    ) {
                        Image(systemName: "gearshape").foregroundStyle(
                            Color.content)
                    }

                    Text(title)
                        .font(.title3.weight(.bold))

                }.frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: Padding.regular) {
                    Button(action: {
                        activeSheet = .pendingList
                    }) {
                        pendingListsCount != 0
                            ? Image(systemName: "bell.badge")
                            : Image(systemName: "bell")
                    }
                }.frame(alignment: .trailing)
            }.foregroundStyle(Color.content)
                .padding(.horizontal, Padding.gutter)
            VStack {
                Spacer()
                Divider().background(Color.surfaceLight)
            }
            .padding(.horizontal, Padding.gutter)
        }
        .frame(height: 64)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

//#Preview {
//    NavigationBar(title: "Title")
//}
