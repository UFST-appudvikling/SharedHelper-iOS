//
//  SwiftUIView.swift
//  
//
//  Created by Nicolai Dam on 03/06/2023.
//

import SwiftUI

/// QA login button view that uses the AutomatedLoginSelection view under the hood
/// The callback is triggered whenever either manual or automated login is chosen and should be used to override the AuthenticationHandler environment in the app
/// - Example of AutomatedLoginButton used as a ToolbarItem:
/// ````
///#if !RELEASE
///.toolbar  {
///    ToolbarItem(placement: .bottomBar) {
///        AutomatedLoginButton(
///            jsonFileURL: Bundle.main.url(forResource: "automated_login_ejerskifte", withExtension: "json")!
///        ) { callback in
///            switch callback {
///            case .Manual:
///                // Manual login chosen
///                // TODO: Override AuthenticationHandler instance for app
///            case .Automated(let userItem, let url):
///                // Automated user is chosen
///                // TODO: Override AuthenticationHandler instance for app
///            }
///        }
///    }
///}
///#endif
/// ````
public struct AutomatedLoginButton: View {
    
    @State var showAutomatedLogin = false
    let jsonFileURL: URL
    let filterUsers: AutomatedLoginSelection.FilterUsers
    let onCallback: (AutomatedLoginSelection.Callback) -> Void

    /// - Parameter jsonFilePath: File path for json file, could for example be: Bundle.main.url(forResource: "automated_login_ejerskifte", withExtension: "json")!
    /// - Parameter filterUsers: Enum of type FilterUsers used to filter user (relevant if there are both azure and dcs users in the json file, the default is .all)
    /// - Parameter callback: Is triggered when there is picked a automated user or manual login
    /// - Returns: View
    public init(jsonFileURL: URL, filterUsers: AutomatedLoginSelection.FilterUsers = .all, onCallback: @escaping (AutomatedLoginSelection.Callback) -> Void) {
        self.jsonFileURL = jsonFileURL
        self.filterUsers = filterUsers
        self.onCallback = onCallback
    }
    
    public var body: some View {
        Button("QA Login") {
            showAutomatedLogin = true
        }
        .padding()
        .sheet(
            isPresented: $showAutomatedLogin,
            content: {
                AutomatedLoginSelection(
                    jsonFilePath: jsonFileURL,
                    filterUsers: filterUsers
                ) {
                    onCallback($0)
                    self.showAutomatedLogin = false
                }
            }
        )
    }
}
