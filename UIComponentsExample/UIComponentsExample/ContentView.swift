//
//  ContentView.swift
//  UIComponentsExample
//
//  Created by Nicolai Dam on 14/02/2023.
//

import SwiftUI
import UIComponents

struct ContentView: View {
    
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
        ContentView()
    }
}

struct SuccessOverlayExample: View {
    
    @State var showSuccessOverlay: Bool = false
    
    var body: some View {
        Button("Show success") {
            showSuccessOverlay = true
        }
        .successOverlay(
            message: "message",
            showSuccessOverlay: $showSuccessOverlay
        ) {
            //Navigation callback triggered here
            showSuccessOverlay = false
        }
    }
}


struct FeedbackExample: View {
    
    @State var showFeedback: Bool = false
    
    var body: some View {
        Button("Show feedback") {
            showFeedback = true
        }
        .feedback(
            showFeedback: $showFeedback,
            primaryColor: .cyan,
            secondaryColor: .red
        ) { providedFeedback in
            // Submit feedback callback triggered
        }
    }
}
