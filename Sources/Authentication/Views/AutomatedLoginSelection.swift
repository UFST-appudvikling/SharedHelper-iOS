//
//  AutomatedLoginSelection.swift
//  
//
//  Created by Nicolai Dam on 17/05/2023.
//

import SwiftUI

/// User selection view used for automated login
public struct AutomatedLoginSelection: View {
    
    @State var users: [UserItem] = []
    @State var url: String = ""
    
    let callback: (Callback) -> Void
    let jsonFilePath: URL
    let filterUsers: FilterUsers
    @State var selectedUser: String = ""
    @State var error: String?
    
    /// - Parameter jsonFilePath: File path for json file, could for example be: Bundle.main.url(forResource: "automated_login_ejerskifte", withExtension: "json")!, this json should be in the AutomatedLoginJSON type
    /// - Parameter filterUsers: Enum of type FilterUsers used to filter user (relevant if there is both azure and dcs users in the json file)
    /// - Parameter callback: Is triggered when there is picked a user
    /// - Returns: View
    public init(
        jsonFilePath: URL,
        filterUsers: FilterUsers = .all,
        callback: @escaping (AutomatedLoginSelection.Callback) -> Void
    ) {
        self.jsonFilePath = jsonFilePath
        self.filterUsers = filterUsers
        self.callback = callback
    }
    
    public var body: some View {
        NavigationView {
            content
            .navigationTitle("QA Login")
            .onAppear { onAppear() }
        }
    }
}

private extension AutomatedLoginSelection {
    var content: some View {
        Group {
            if let error {
                Text(error)
            } else {
                List {
                    userPicker
                }
            }
        }
    }
    
    @ViewBuilder
    var userPicker: some View {
        Section("Manual") {
            Button {
                callback(.Manual)
            } label: {
                Text("Choose OAuth login")
                    .foregroundColor(Color.cyan)
                    .font(.title2)
            }
        }
        Section("Automated") {
            Picker(
                "Select user",
                selection: $selectedUser
            ) {
                ForEach(users, id: \.self) { user in
                    switch user {
                    case .azure(let azureUser):
                        Text(azureUser.title)
                            .tag(azureUser.title)
                    case .dcs(let dcsUser):
                        Text(dcsUser.title)
                            .tag(dcsUser.title)
                    }
                }
            }
            Button {
                for user in users {
                    switch user {
                    case .dcs(let automatedLoginDCSUser):
                        if automatedLoginDCSUser.title == selectedUser {
                            callback(.Automated(.dcs(automatedLoginDCSUser), self.url))
                        }
                    case .azure(let automatedLoginAzureUser):
                        if automatedLoginAzureUser.title == selectedUser {
                            callback(.Automated(.azure(automatedLoginAzureUser), self.url))
                        }
                    }
                }
            } label: {
                Text("Choose automated login")
                    .foregroundColor(Color.cyan)
                    .font(.title2)
            }
        }
    }
}

private extension AutomatedLoginSelection {
    func onAppear() {
        do {
            
            let data = try Data(contentsOf: self.jsonFilePath)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(AuthenticationHandler.AutomatedLoginJSON.self, from: data)
            
            switch self.filterUsers {
            case .all:
                self.users = jsonData.users
            case .dcsOnly:
                for user in jsonData.users {
                    if case .dcs = user {
                        self.users.append(user)
                    }
                }
            case .azureOnly:
                for user in jsonData.users {
                    if case .azure = user {
                        self.users.append(user)
                    }
                }
            }
            
            self.url = jsonData.url
        
            guard let firstUser = self.users.first else { fatalError("Could not find first user") }
            
            switch firstUser {
            case .dcs(let automatedLoginDCSUser):
                self.selectedUser = automatedLoginDCSUser.title
                break
            case .azure(let automatedLoginAzureUser):
                self.selectedUser = automatedLoginAzureUser.title
                break
            }
            
        } catch let error {
            self.error = "Error decoding json file: \(error.localizedDescription)"
        }
    }
}

public extension AutomatedLoginSelection {
    
    enum Callback: Equatable {
        case Manual
        case Automated(UserItem, String)
    }
    
    enum FilterUsers {
        case all
        case dcsOnly
        case azureOnly
    }
}
