//
//  File.swift
//  
//
//  Created by Emad Ghorbaninia on 30/01/2023.
//

import SwiftUI
extension AuthenticationHandler {
    static func userSelectorHostingController(users: [TokenConfiguration], selectedUserHandler: @escaping (TokenConfiguration) -> ()) -> UIViewController {
        UIHostingController(rootView: UserSelector(users: users, selectedUserHandler: selectedUserHandler))
    }
    struct UserSelector: View {
        private var selectedUserHandler: (TokenConfiguration) -> ()
        let users: [TokenConfiguration]
        
        init(users: [TokenConfiguration], selectedUserHandler: @escaping (TokenConfiguration) -> ()) {
            self.users = users
            self.selectedUserHandler = selectedUserHandler
        }

        var body: some View {
            List(users, id: \.self) { user in
                HStack {
                    Text(user.azure.name)
                    Spacer()
                    Text(user.azure.email)
                }
                .padding()
                .onTapGesture {
                    selectedUserHandler(user)
                }
            }
        }
    }
    
}
