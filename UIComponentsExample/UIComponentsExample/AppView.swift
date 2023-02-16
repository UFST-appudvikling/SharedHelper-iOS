//
//  UIComponentsExampleApp.swift
//  UIComponentsExample
//
//  Created by Nicolai Dam on 14/02/2023.
//

import SwiftUI

@main
struct UIComponentsExampleApp: App {
    var body: some Scene {
        WindowGroup {
            AppView()
        }
    }
}

struct AppView: View {
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Success overlay") {
                    SuccessOverlayExample()
                }
                NavigationLink("Feedback") {
                    FeedbackExample()
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("UI Components")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
