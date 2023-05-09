//
//  File.swift
//  
//
//  Created by Nicolai Dam on 13/02/2023.
//

import SwiftUI

public struct FeedbackStyling {
    
    let primaryButtonColor: Color
    let secondaryColor: Color
    let bodyTextColor: Color
    let borderColor: Color
    let backgroundColor: Color
    
    public init(
        primaryButtonColor: Color = Color.CustomColor.green,
        secondaryColor: Color = Color.CustomColor.darkBlue,
        bodyTextColor: Color = Color.CustomColor.grayishBlue,
        borderColor: Color = Color.CustomColor.grayishBlue,
        backgroundColor: Color = Color.CustomColor.white
    ) {
        self.primaryButtonColor = primaryButtonColor
        self.secondaryColor = secondaryColor
        self.bodyTextColor = bodyTextColor
        self.borderColor = borderColor
        self.backgroundColor = backgroundColor
    }
}

public struct FeedbackLocalization {
    
    let header: String
    let boxTitle: String
    let privacyPolicyDisclamer: String
    let primaryButtonText: String
    let successMessage: String
    
    public init(header: String, boxTitle: String, privacyPolicyDisclamer: String, primaryButtonText: String, successMessage: String) {
        self.header = header
        self.boxTitle = boxTitle
        self.privacyPolicyDisclamer = privacyPolicyDisclamer
        self.primaryButtonText = primaryButtonText
        self.successMessage = successMessage
    }
}

public extension View {
    
    /**
     Feedback popup
     
     - Parameter showFeedback: Decides when overlay should be shown
     - Parameter localization: Localization strings
     - Parameter styling: Customized UI styling
     - Parameter onCloseButtonTap: Triggered when user taps on close button.
         Note that this callback should only be used for analytics tracking since the navigation mechanismback to the app is handled in the modifier itself
     - Parameter submitFeedback: Triggered when the user submits feedback
     */
    
    func feedback(
        showFeedback: Binding<Bool>,
        localization: FeedbackLocalization,
        styling: FeedbackStyling = .init(),
        onCloseButtonTap: @escaping () -> Void,
        submitFeedback: @escaping (_ providedFeedback: String) -> Void
    ) -> some View {
        modifier(
            FeedbackViewModifier(
                showFeedback: showFeedback,
                styling: styling,
                localization: localization,
                onCloseButtonTap: onCloseButtonTap,
                submitFeedback: submitFeedback
            )
        )
    }
}


struct FeedbackViewModifier: ViewModifier {
    
    @Binding var showFeedback: Bool
    let styling: FeedbackStyling
    let localization: FeedbackLocalization
    let onCloseButtonTap: () -> Void
    let submitFeedback: (_ input: String) -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if showFeedback {
                FeedbackView(
                    showFeedbackOverlay: $showFeedback,
                    submitFeedback: submitFeedback,
                    onCloseButtonTap: onCloseButtonTap,
                    localization: localization,
                    styling: styling
                )
            }
        }
        .animation(.default, value: showFeedback)
    }
}


struct FeedbackView: View {
    
    @Binding var showFeedbackOverlay: Bool
    let submitFeedback: (_ providedFeedback: String) -> Void
    let onCloseButtonTap: () -> Void
    @State var inputTextField: String = ""
    @FocusState var textfieldIsFocused: Bool
    @State var showSuccess: Bool = false
    var disableSubmitButton: Bool {
        inputTextField.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    let localization: FeedbackLocalization
    let styling: FeedbackStyling
    
    
    public var body: some View {
        content
            .animation(.easeInOut, value: showFeedbackOverlay)
    }
}

private extension FeedbackView {
    
    var content: some View {
        ZStack {
            backgroundView
            if showSuccess {
                SuccessOverlayView(message: self.localization.successMessage)
                    .onAppear {
                        Task {
                            try await Task.sleep(nanoseconds: 3_000_000_000)
                            withAnimation {
                                showFeedbackOverlay = false
                            }
                        }
                    }
            } else {
                feedbackView
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(4)
                    .overlay { closeButton }
                    .padding(16)
                    .accessibilityAddTraits(.isModal)
            }
        }
        .onChange(of: showFeedbackOverlay) { newValue in
            if newValue {
                self.textfieldIsFocused = true
            }
        }
        .animation(.default, value: inputTextField)
        .animation(.default, value: showSuccess)
        
    }
    
    var closeButton: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    self.textfieldIsFocused = false
                    withAnimation {
                        self.showFeedbackOverlay = false
                    }
                    self.onCloseButtonTap()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .padding(.all, 20)
                        .foregroundColor(styling.secondaryColor)
                }
            }
            Spacer()
        }
    }
    
    var backgroundView: some View {
            Rectangle()
                .ignoresSafeArea()
                .foregroundColor(.black)
                .opacity(0.2)
    }
    
    var feedbackView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(localization.header)
                .font(Font.academySans(size: 28, type: .skatBold))
                .foregroundColor(styling.secondaryColor)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.top, 30)
            Text(localization.boxTitle)
                .font(Font.academySans(size: 17, type: .skatRegular))
                .foregroundColor(styling.secondaryColor)
            TextEditor(text: $inputTextField)
                .padding(.all, 10)
                .focused($textfieldIsFocused)
                .accessibilityHint(localization.privacyPolicyDisclamer)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .onAppear {
                    // Setting keyboard to focused if voice is not running
                    if !UIAccessibility.isVoiceOverRunning {
                        self.textfieldIsFocused = true
                    }
                }
                .font(Font.academySans(size: 17, type: .skatRegular))
                .foregroundColor(styling.bodyTextColor)
                .background(styling.backgroundColor)
            Text(localization.privacyPolicyDisclamer)
                .font(Font.academySans(size: 11, type: .skatRegular))
                .foregroundColor(styling.secondaryColor)
                .accessibilityHidden(true)
            HStack {
                Button {
                    self.textfieldIsFocused = false
                    self.showSuccess = true
                    self.submitFeedback(inputTextField)
                } label: {
                    Text(localization.primaryButtonText)
                        .frame(maxWidth: .infinity)
                }
                .disabled(disableSubmitButton)
                .font(Font.academySans(size: 17, type: .skatBold))
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(styling.primaryButtonColor)
                .foregroundColor(.white)
                .cornerRadius(4)
                .opacity(disableSubmitButton ? 0.6 : 1.0)
                .multilineTextAlignment(.center)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView(showFeedbackOverlay: .constant(true), submitFeedback: { _ in }, onCloseButtonTap: {}, localization: FeedbackLocalization(
            header: "Hvordan kan vi forbedre appen?",
            boxTitle: "Skriv dine forbedringsidéer her",
            privacyPolicyDisclamer: "Ingen personfølsomme oplysninger i denne boks. ",
            primaryButtonText: "Indsend",
            successMessage: "Tusind tak for din feedback!"
        ), styling: .init())
    }
}
