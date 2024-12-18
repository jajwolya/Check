//
//  AuthenticationView.swift
//  Check
//
//  Created by Jajwol Bajracharya on 13/12/2024.
//

import SwiftUI

struct AuthenticationView: View {
    @Binding var showSignInView: Bool
    var body: some View {
        VStack {
            NavigationLink {
                SignInEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Sign in with email")
            }
        }
        .navigationTitle("Sign in")
    }

}

#Preview {
    NavigationStack {
        AuthenticationView(showSignInView: .constant(false))
    }
}
