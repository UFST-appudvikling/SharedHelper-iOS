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
        List {
            Button("Show success") {
                showSuccessOverlay = true
            }
        }
        .navigationTitle("Success overlay")
        .successOverlay(
            message: "Thanks for using UIComponents",
            showSuccessOverlay: $showSuccessOverlay
        ) {
            showSuccessOverlay = false
        }
    }
}


struct FeedbackExample: View {
    
    @State var showFeedback: Bool = false
    
    let localization = FeedbackLocalization(
        header: "Hvordan kan vi forbedre appen?",
        boxTitle: "Skriv dine forbedringsidéer her",
        privacyPolicyDisclamer: "Ingen personfølsomme oplysninger i denne boks. ",
        primaryButtonText: "Indsend",
        successMessage: "Tusind tak for din feedback!"
    )
    
    var body: some View {
        List {
            Button("Show feedback") {
                showFeedback = true
            }
        }
        .navigationTitle("Feedback")
        .feedback(
            showFeedback: $showFeedback,
            localization: localization
        ) { providedFeedback in
            // Submit feedback callback triggered
        }
    }
}
