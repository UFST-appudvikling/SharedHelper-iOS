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
    @State var primaryButtonColor: Color = .cyan
    
    let localization = FeedbackLocalization(
        header: "Hvordan kan vi forbedre appen?",
        boxTitle: "Skriv dine forbedringsidéer her",
        privacyPolicyDisclamer: "Ingen personfølsomme oplysninger i denne boks. ",
        primaryButtonText: "Indsend",
        successMessage: "Tusind tak for din feedback!"
    )
    
    var body: some View {
        List {
            Section("This component is developed with reusability and customizability in mind.\nFor example you can change the color of the primary button if you want to.") {
                ColorPicker("Change color 😎", selection: $primaryButtonColor)
            }
            Button("Start feedback") {
                showFeedback = true
            }
        }
        .navigationTitle("Feedback")
        .feedback(
            showFeedback: $showFeedback,
            localization: localization,
            styling: .init(primaryButtonColor: primaryButtonColor),
            onCloseButtonTap: { },
            submitFeedback: { providedFeedback in }
        )
    }
}
