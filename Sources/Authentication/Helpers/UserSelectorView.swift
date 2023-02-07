//
//  File.swift
//  
//
//  Created by Emad Ghorbaninia on 30/01/2023.
//

import SwiftUI
extension AuthenticationHandler {
    struct UserSelector: View {
        let users: [TokenConfiguration]
        @State var selectedUser: TokenConfiguration

        var body: some View {
            List(users, id: \.self) { user in
                HStack {
                    Text(user.azure.name)
                    Spacer()
                    Text(user.azure.email)
                }
                .padding()
                .onTapGesture {
                   selectedUser = user
                }
            }
        }
    }
}
