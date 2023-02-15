//
//  File.swift
//  
//
//  Created by Nicolai Dam on 13/02/2023.
//

import SwiftUI

public struct SuccessOverlayStyling {
    
    let messageFont: Font
    let messageColor: Color
    let checkmarkColor: Color
    
    public init(
        messageFont: Font = Font.academySans(size: 18, type: .skat_demiBold),
        messageColor: Color = Color(#colorLiteral(red: 0.1018853113, green: 0.1138664857, blue: 0.3018276095, alpha: 1)),
        checkmarkColor: Color = Color(#colorLiteral(red: 0, green: 0.5058823529, blue: 0.2235294118, alpha: 1))
    ) {
        self.messageFont = messageFont
        self.messageColor = messageColor
        self.checkmarkColor = checkmarkColor
    }
}

public extension View {
    
    /**
     Success overlay animation
     
     - Parameter message: Message displayed on success overlay
     - Parameter showSuccessOverlay: Decides when overlay should be shown
     - Parameter delayUntilNavigationCallback: Delay time before navigationCallback is triggered, default value is 2.5 seconds
     - Parameter navigationCallback: Trigger when parent view should navigate to next step in flow
     */
    
    func successOverlay(
        message: String,
        showSuccessOverlay: Binding<Bool>,
        delayUntilNavigationCallback: Double = 2.5,
        styling: SuccessOverlayStyling = .init(),
        navigationCallback: @escaping () -> Void
    ) -> some View {
        modifier(
            SuccessOverlayViewModifier(
                showSuccessOverlay: showSuccessOverlay,
                navigateCallback: navigationCallback,
                message: message,
                animationDelay: delayUntilNavigationCallback,
                styling: styling
            )
        )
    }
}


struct SuccessOverlayViewModifier: ViewModifier {
    
    @Binding var showSuccessOverlay: Bool
    let navigateCallback: () -> Void
    let message: String
    let animationDelay: Double
    let styling: SuccessOverlayStyling
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if showSuccessOverlay {
                SuccessOverlayView(message: message, styling: styling)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) {
                            navigateCallback()
                        }
                    }
            }
        }
    }
}


struct SuccessOverlayView: View {
    
    let message: String
    let styling: SuccessOverlayStyling
    @State private var showAlert = false
    @State private var alertDidAppear = false
    @State private var isModal = true
    @AccessibilityFocusState private var isFocused: Bool
    
    init(message: String, styling: SuccessOverlayStyling = .init()) {
        self.message = message
        self.styling = styling
    }
    
    public var body: some View {
        content
            .onDisappear {
                self.isFocused = false
                self.isModal = false
            }
            .onChange(
                of: showAlert,
                perform: { newValue in
                    if showAlert {
                        //A delay is needed here to get the accessibility focus working
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.isFocused = true
                        }
                    }
                }
            )
    }
}

private extension SuccessOverlayView {
    
    var content: some View {
        ZStack {
            backgroundView
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            self.showAlert = true
                        }
                    }
                }
            if showAlert {
                alertView
                    // Fix so voiceover stays on the "message" while success overlay is shown
                    .if(self.isModal) {
                        $0.accessibility(addTraits: .isModal)
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.spring(response: 0.7, dampingFraction: 0.925, blendDuration: 10)) {
                                alertDidAppear = true
                            }
                        }
                    }
                    .transition(.opacity)
                    .padding(50)
                    .background(Color.white)
                    .cornerRadius(4)
                    .padding(10)
            }
        }
    }
    
    var backgroundView: some View {
        Color.black
            .opacity(0.4)
            .ignoresSafeArea()
    }
    
    var alertView: some View {
        VStack(alignment: .center, spacing: 20) {
            Image("Success", bundle: .myModule)
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(styling.checkmarkColor)
                .scaleEffect(alertDidAppear ? 1 : 0)
            Text(message)
                .font(styling.messageFont)
                .foregroundColor(styling.messageColor)
                .multilineTextAlignment(.center)
                .accessibilityFocused($isFocused)
        }
    }
}
