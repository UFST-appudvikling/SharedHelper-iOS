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
        primaryButtonColor: Color = Color(#colorLiteral(red: 0, green: 0.5659442544, blue: 0.287532568, alpha: 1)),
        secondaryColor: Color = Color(#colorLiteral(red: 0.1018853113, green: 0.1138664857, blue: 0.3018276095, alpha: 1)),
        bodyTextColor: Color = Color(#colorLiteral(red: 0.262745098, green: 0.262745098, blue: 0.3882352941, alpha: 1)),
        borderColor: Color = Color(#colorLiteral(red: 0.262745098, green: 0.262745098, blue: 0.3882352941, alpha: 1)),
        backgroundColor: Color = Color(#colorLiteral(red: 1, green: 0.9999999404, blue: 0.9999999404, alpha: 1))
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
    /// Rating alert
    /// - Parameter title: title displayed on rating pop up
    /// - Parameter message: Message displayed on rating pop up
    /// - Parameter showRatingOverlay: Decides when overlay should be shown
    func feedback(
        showFeedback: Binding<Bool>,
        localization: FeedbackLocalization,
        styling: FeedbackStyling = .init(),
        submitFeedbackCallback: @escaping (_ providedFeedback: String) -> Void
    ) -> some View {
        modifier(
            RatingAlertViewModifier(
                showFeedback: showFeedback,
                styling: styling,
                localization: localization,
                submitFeedbackCallback: submitFeedbackCallback
            )
        )
    }
}


struct RatingAlertViewModifier: ViewModifier {
    
    @Binding var showFeedback: Bool
    let styling: FeedbackStyling
    let localization: FeedbackLocalization
    let submitFeedbackCallback: (_ input: String) -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if showFeedback {
                RatingAlertView2(showFeedbackOverlay: $showFeedback, submitFeedbackCallback: submitFeedbackCallback, localization: localization, styling: styling)
            }
        }
        .animation(.default, value: showFeedback)
    }
}


struct RatingAlertView2: View {
    
    @Binding var showFeedbackOverlay: Bool
    let submitFeedbackCallback: (_ providedFeedback: String) -> Void
    @State var inputTextField: String = ""
    @FocusState var textfieldIsFocused: Bool
    @State var showSuccess: Bool = false
    
    let localization: FeedbackLocalization
    let styling: FeedbackStyling
    
    
    public var body: some View {
        content
            .animation(.easeInOut, value: showFeedbackOverlay)
    }
}

private extension RatingAlertView2 {
    
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
                alertView
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(4)
                    .overlay {
                        VStack {
                            HStack {
                                Spacer()
                                Button {
                                    self.textfieldIsFocused = false
                                    withAnimation {
                                        self.showFeedbackOverlay = false
                                    }
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
                    .padding(16)
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
    
    @ViewBuilder
    var backgroundView: some View {
        if #available(iOS 16.0, *) {
            Rectangle()
                .ignoresSafeArea()
                .toolbar(.hidden, for: .tabBar)
                .foregroundColor(.black)
                .opacity(0.2)
        } else {
            Rectangle()
                .ignoresSafeArea()
                .foregroundColor(.black)
                .opacity(0.2)
        }
    }
    
    var alertView: some View {
        VStack(alignment: .center, spacing: 20) {
            Text(localization.header)
                .font(Font.academySans(size: 28, type: .skat_bold))
                .foregroundColor(styling.secondaryColor)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 56)
                .padding(.horizontal, 20)
            TextEditor(text: $inputTextField)
                .padding(.all, 10)
                .focused($textfieldIsFocused)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .onAppear {
                    self.textfieldIsFocused = true
                }
                .font(Font.academySans(size: 17, type: .skat_regular))
                .foregroundColor(styling.bodyTextColor)
                .background(styling.backgroundColor)
            HStack {
                Button {
                        self.textfieldIsFocused = false
                        self.showSuccess = true
                        self.submitFeedbackCallback(inputTextField)
                } label: {
                    Text(localization.primaryButtonText)
                        .frame(maxWidth: .infinity)
                }
                .disabled(inputTextField.trimmingCharacters(in: .whitespaces).isEmpty)
                .font(Font.academySans(size: 17, type: .skat_bold))
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(styling.primaryButtonColor)
                .foregroundColor(.white)
                .cornerRadius(4)
                .opacity(inputTextField.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
                .multilineTextAlignment(.center)
            }
        }
    }
}


