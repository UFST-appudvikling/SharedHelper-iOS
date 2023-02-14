//
//  File.swift
//  
//
//  Created by Nicolai Dam on 13/02/2023.
//

import SwiftUI

public extension View {
    /// Rating alert
    /// - Parameter title: title displayed on rating pop up
    /// - Parameter message: Message displayed on rating pop up
    /// - Parameter showRatingOverlay: Decides when overlay should be shown
    func feedback(
        showFeedback: Binding<Bool>,
        primaryColor: UIColor,
        secondaryColor: UIColor,
        submitFeedbackCallback: @escaping (_ input: String) -> Void
    ) -> some View {
        modifier(
            RatingAlertViewModifier(
                showFeedback: showFeedback,
                primaryColor: primaryColor,
                secondaryColor: secondaryColor,
                submitFeedbackCallback: submitFeedbackCallback
            )
        )
    }
}


struct RatingAlertViewModifier: ViewModifier {
    
    @Binding var showFeedback: Bool
    let primaryColor: UIColor
    let secondaryColor: UIColor
    let submitFeedbackCallback: (_ input: String) -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if showFeedback {
                RatingAlertView2(showFeedbackOverlay: $showFeedback, submitFeedbackCallback: submitFeedbackCallback)
            }
        }
        .animation(.default, value: showFeedback)
    }
}


struct RatingAlertView2: View {
    
    @Binding var showFeedbackOverlay: Bool
    let submitFeedbackCallback: (_ input: String) -> Void
    @State var inputTextField: String = ""
    @FocusState var textfieldIsFocused: Bool
    @State var showSuccess: Bool = false
    
    internal init(showFeedbackOverlay: Binding<Bool>, submitFeedbackCallback: @escaping (_ input: String) -> Void) {
        self._showFeedbackOverlay = showFeedbackOverlay
        self.submitFeedbackCallback = submitFeedbackCallback
    }
    
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
                SuccessOverlayView(message: "Tusinde tak for din feedback!")
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
//                                        .foregroundColor(.esHeader)
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
            Text("Hvordan kan vi forbedre appen?")
//                .skatFont(.heading2)
//                .foregroundColor(Color.esHeader)
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
//                .skatFont(.labelBold1)
//                .foregroundColor(.esBodyText)
                .background(Color.white)
            //
            HStack {
                Button {
                        self.textfieldIsFocused = false
                        self.showSuccess = true
                        self.submitFeedbackCallback(inputTextField)
                } label: {
                    Text("Indsend")
                        .frame(maxWidth: .infinity)
                }
                .disabled(inputTextField.trimmingCharacters(in: .whitespaces).isEmpty)
//                .skatFont(.labelBold1)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
//                .background(Color.esActionPrimary)
                .foregroundColor(.white)
                .cornerRadius(4)
                .opacity(inputTextField.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
                .multilineTextAlignment(.center)
            }
        }
    }
}

private struct FeedbackPreviewHelper: View {
    @State var showFeedback = false
    var body: some View {
        Button("Test overlay") {
            self.showFeedback = true
        }
        .feedback(
            showFeedback: $showFeedback,
            primaryColor: .red,
            secondaryColor: .cyan
        ) { _ in }
    }
}

struct Feedback_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackPreviewHelper()
    }
}



