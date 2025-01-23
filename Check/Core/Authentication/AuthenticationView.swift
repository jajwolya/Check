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
        VStack(spacing: 96) {
            Image("AppIconSVG")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 96.0, height: 96.0)
            
            VStack(spacing: Padding.medium) {
                NavigationLink {
                    SignInEmailView(showSignInView: $showSignInView, isSignUp: true)
                } label: {
                    Text("Sign up")
                        .fontWeight(.medium)
                        .foregroundStyle(Color.surfaceBackground)
                        .padding(Padding.regular)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .fill(Color.light))
                }
                
                NavigationLink {
                    SignInEmailView(showSignInView: $showSignInView)
                } label: {
                    Text("Sign in")
                        .fontWeight(.medium)
                        .foregroundStyle(Color.content)
                        .padding(Padding.regular)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.medium)
                                .fill(Color.surface))
                }
                
            }

            
        }.padding(Padding.gutter)
    }

}

#Preview {
    NavigationStack {
        AuthenticationView(showSignInView: .constant(false))
    }
}
