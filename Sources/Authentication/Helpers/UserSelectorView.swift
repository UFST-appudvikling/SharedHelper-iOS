//
//  File.swift
//  
//
//  Created by Emad Ghorbaninia on 30/01/2023.
//

import SwiftUI
public extension AuthenticationHandler {
    struct UserSelector: View {
        public let users: [TokenConfiguration]
        @State public var selectedUser: TokenConfiguration
        
        public var body: some View {
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
