//
//  EditCategoryDialog.swift
//  Check
//
//  Created by Jajwol Bajracharya on 31/12/2024.
//

import SwiftUI

struct CustomDialog: View {
    @Binding var showDialog: Bool
//    let title: String
    let prompt: String
    let options: [(name: String, action: () -> Task<Void, Never>)]
    @State private var offset: CGFloat = 500
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    closeDialog()
                }
            VStack {
                Spacer()
                VStack(spacing: Padding.small) {
//                   Text(title).font(.body).fontWeight(.semibold)
//                        .padding(.vertical, Padding.small)
//                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(prompt).font(.caption).padding(.vertical, Padding.small)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ForEach(options.indices, id: \.self) { index in
                        Divider().background(Color.surfaceLight)
                        Button(action: {
                            options[index].action()
                            closeDialog()
                        }) {
                            Text(options[index].name)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, Padding.small)
                        .foregroundColor(Color.content)
                    }
                }
                .padding(Padding.regular)
                .foregroundStyle(Color.content)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.regular)
                        .fill(Color.surface)
                )
                
                Button(action: {
                    closeDialog()
                }){
                    Text("Cancel").font(.body).fontWeight(.semibold)
                }
                .foregroundStyle(Color.content)
                .padding(Padding.regular)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.regular)
                        .fill(Color.surface)
                )
                
            }
            .padding(Padding.gutter)
            .offset(x: 0, y: offset)
                        .onAppear {
                            withAnimation(.spring()) {
                                offset = 0
                            }
                        }
            
        }
        
        
    }
    
    func closeDialog() {
        withAnimation(.spring()) {
            offset = 500
            showDialog = false
        }
    }
}

//#Preview {
//    let options = [
//        (name: "Delete category", action: { print("Option 1 selected") }),
//        (name: "Rename category", action: { print("Option 2 selected") })
//    ]
//    EditCategoryDialog(showDialog: .constant(true), title: "Title", options: options)
//}
