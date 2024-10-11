//
//  BackButtonView.swift
//  Reciplease
//
//  Created by Bilal D on 11/10/2024.
//

import SwiftUI

struct BackButtonView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("< Back")
                .foregroundStyle(Color("WhiteFont"))
                .font(.custom("PlusJakartaSans-Semibold", size: 14))
        }
    }
}

#Preview {
    BackButtonView()
}
