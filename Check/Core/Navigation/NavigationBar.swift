//
//  NavigationBar.swift
//  Check
//
//  Created by Jajwol Bajracharya on 19/12/2024.
//

import SwiftUI

struct NavigationBar: View {
    var title: String
    
    var body: some View {
        ZStack {
            Color(.surfaceDark).ignoresSafeArea()
            Text(title)
                .foregroundStyle(Color.white)
                .font(.largeTitle.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Padding.gutter)
        }
        .frame(height: 64)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    NavigationBar(title: "Title")
}
