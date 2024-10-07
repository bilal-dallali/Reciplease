//
//  ContentView.swift
//  Reciplease
//
//  Created by Bilal D on 26/09/2024.
//

import SwiftUI

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct ContentView: View {
    
    @State var ingredientsText: String = ""
    
    var body: some View {
        VStack {
            VStack(spacing: 22) {
                VStack(spacing: 15) {
                    Text("Reciplease")
                        .foregroundStyle(Color("WhiteFont"))
                        .font(.custom("Gutheng", size: 25))
                    VStack(spacing: 16) {
                        Text("What’s in your fridge ?")
                            .foregroundStyle(Color("DarkFont"))
                            .font(.custom("PlusJakartaSans-Medium", size: 24))
                        HStack(spacing: 10) {
                            TextField("", text: $ingredientsText)
                                .placeholder(when: ingredientsText.isEmpty) {
                                    Text("Lemon, Cheese, Sausages...")
                                        .foregroundColor(Color("GreyFont"))
                                        .font(.custom("PlusJakartaSans-Medium", size: 19))
                                }
                                .autocapitalization(.none)
                                .keyboardType(.default)
                                .font(.custom("PlusJakartaSans-Medium", size: 19))
                                .foregroundColor(Color("DarkFont"))
                                .frame(width: 260, height: 26)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(Color("GreyFont"))
                                        .padding(.top), alignment: .bottom
                                )
                            Button {
                                print("Add")
                            } label: {
                                Text("Add")
                                    .foregroundStyle(Color("WhiteFont"))
                                    .font(.custom("PlusJakartaSans-Medium", size: 19))
                                    .frame(width: 75, height: 40)
                                    .background(Color("GreenButton"))
                                    .cornerRadius(3)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .padding(.top, 24)
                    .padding(.bottom, 19)
                    .background(Color("WhiteFont"))
                }
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Your ingredients :")
                            .foregroundStyle(Color("WhiteFont"))
                            .font(.custom("Gutheng", size: 24))
                        Spacer()
                        Button {
                            print("clear")
                        } label: {
                            Text("Clear")
                                .foregroundStyle(Color("WhiteFont"))
                                .font(.custom("PlusJakartaSans-Medium", size: 19))
                                .frame(width: 75, height: 40)
                                .background(Color("GreyFont"))
                                .cornerRadius(3)
                        }

                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text("- Apple")
                            .foregroundStyle(Color("WhiteFont"))
                            .font(.custom("Gutheng", size: 24))
                        Text("- Tomato")
                            .foregroundStyle(Color("WhiteFont"))
                            .font(.custom("Gutheng", size: 24))
                        Text("- Curry")
                            .foregroundStyle(Color("WhiteFont"))
                            .font(.custom("Gutheng", size: 24))
                        Text("- Chicken")
                            .foregroundStyle(Color("WhiteFont"))
                            .font(.custom("Gutheng", size: 24))
                    }
                    
                }
                .padding(.horizontal, 20)
            }
            Spacer()
            Button {
                print("Search for recipes")
            } label: {
                Text("Search for recipes")
                    .foregroundStyle(Color("WhiteFont"))
                    .font(.custom("PlusJakartaSans-Semibold", size: 23))
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Color("GreenButton"))
                    .cornerRadius(3)
                    .padding(.horizontal, 35)
            }

        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 25)
        .background(Color("Background"))
        
    }
}

#Preview {
    ContentView()
}
