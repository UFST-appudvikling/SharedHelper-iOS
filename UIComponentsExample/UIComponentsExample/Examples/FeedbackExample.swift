//
//  Feedback.swift
//  UIComponentsExample
//
//  Created by Nicolai Dam on 14/02/2023.
//

import SwiftUI
import UIComponents

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
            Button("Start feedback") {
                showFeedback = true
            }
        }
        .navigationTitle("Feedback")
        .feedback(
            showFeedback: $showFeedback,
            localization: localization
        ) { providedFeedback in
            
        }
    }
}
