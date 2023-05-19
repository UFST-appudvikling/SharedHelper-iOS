//
//  AutomatedLoginSelection.swift
//  
//
//  Created by Nicolai Dam on 17/05/2023.
//

import SwiftUI

public struct AutomatedLoginSelection: View {
    
    let callback: (Callback) -> Void
    let automatedUsers: [AuthenticationHandler.TokenConfiguration]
    @State var selectedUser: AuthenticationHandler.TokenConfiguration?
    @Environment(\.dismiss) private var dismiss

    public init(
        callback: @escaping (AutomatedLoginSelection.Callback) -> Void,
        automatedUsers: [AuthenticationHandler.TokenConfiguration]
    ) {
        self.callback = callback
        self.automatedUsers = automatedUsers
    }
    
    public var body: some View {
        NavigationView {
            List {
                Section("Manual") {
                    Button {
                        dismiss()
                        callback(.Manual)
                    } label: {
                        Text("Choose OAuth login")
                    }
                }
                Section("Automated") {
                    Picker(
                        "Select user",
                        selection: $selectedUser
                    ) {
                        ForEach(automatedUsers, id: \.self) { user in
                            Text(user.authenticatedUser?.alternateName ?? "Should be here")
                        }
                    }
                    Button {
                        guard let selectedUser = selectedUser else { fatalError() }
                        dismiss()
                        callback(.Automated(selectedUser))
                    } label: {
                        Text("Choose automated login")
                    }
                }

            }
            .navigationTitle("Login")
            .onAppear {
                self.selectedUser = automatedUsers.first!
            }
        }
    }
}

extension AutomatedLoginSelection {
    public enum Callback: Equatable {
        case Manual
        case Automated(AuthenticationHandler.TokenConfiguration)
    }
}

struct AutomatedLoginSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        AutomatedLoginSelection(callback: { _ in }, automatedUsers: [.mock])
    }
}

extension AuthenticationHandler.TokenConfiguration {
    static let mock = Self.init(
        apiKey: "apiKey",
        clientID: "clientID",
        azureOrDcs: "azureOrDcs",
        nonce: "nonce",
        azure: AuthenticationHandler.AzureModel(name: "Henrik", email: "hej@henrik.dk"),
        authorizations: AuthenticationHandler.AuthorizationsModel(roles: ["SejRolle"])
    )
}
