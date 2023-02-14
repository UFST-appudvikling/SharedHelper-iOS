//
//  File.swift
//  
//
//  Created by Nicolai Dam on 13/02/2023.
//

import SwiftUI

struct SuccessOverlayView: View {
    
    let message: String
    @State private var showAlert = false
    @State private var alertDidAppear = false
    @State private var isModal = true
    @AccessibilityFocusState private var isFocused: Bool
    
    internal init(message: String) {
        self.message = message
    }
    
    public var body: some View {
        content
            .onDisappear(perform: {
                self.isFocused = false
                self.isModal = false
            })
            .onChange(of: showAlert, perform: { newValue in
                if showAlert {
                    //A delay is needed here to get the accessibility focus working
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.isFocused = true
                    }
                }
            })
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
//                    .if(self.isModal) {
//                        $0.accessibility(addTraits: .isModal)
//                    }
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
            Image(systemName: "checkmark")
                .resizable()
                .frame(width: 40, height: 40)
                .scaleEffect(alertDidAppear ? 1 : 0)
            Text(message)
                .font(Font.academySans(size: 18, type: .skat_demiBold))
//                .foregroundColor(.esHeader)
                .multilineTextAlignment(.center)
                .accessibilityFocused($isFocused)
        }
    }
}

struct SuccessOverlayViewModifier: ViewModifier {
    
    @Binding var showSuccessOverlay: Bool
    let navigateCallback: () -> Void
    let message: String
    let animationDelay: Double
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if showSuccessOverlay {
                SuccessOverlayView(message: message)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) {
                            navigateCallback()
                        }
                    }
            }
        }
    }
}

public extension View {
    /// Success overlay animation shown before navigation
    /// - Parameter message: Message displayed on success overlay
    /// - Parameter showSuccessOverlay: Decides when overlay should be shown
    /// - Parameter navigationCallback: Trigger when parent view should navigate to next step in flow
    /// - Parameter animationDelay: Delay time before navigationCallback is triggered, default value is 2.5 seconds
    func successOverlay(
        message: String,
        showSuccessOverlay: Binding<Bool>,
        navigationCallback: @escaping () -> Void,
        animationDelay: Double = 2.5
    ) -> some View {
        modifier(
            SuccessOverlayViewModifier(
                showSuccessOverlay: showSuccessOverlay,
                navigateCallback: navigationCallback,
                message: message,
                animationDelay: animationDelay
            )
        )
    }
}

//private struct previewHelper: View {
//    
//    @State var showSuccessOverlay
//    
//    private body: some View {
//        
//    }
//}
//
//struct SuccessOverlay_Previews: PreviewProvider {
//    static var previews: some View {
//            NavigationView {
//                Text("Text")
//                    .successOverlay(
//                        message: "Message",
//                        showSuccessOverlay: .constant(.),
//                        navigationCallback: {  }
//                    )
//            }
//        }
//}
