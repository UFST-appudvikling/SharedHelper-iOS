//
//  SuccessOverlay.swift
//  UIComponentsExample
//
//  Created by Nicolai Dam on 14/02/2023.
//

import SwiftUI
import UIComponents

struct SuccessOverlayExample: View {
    
    @State var showSuccessOverlay: Bool = false
    
    var body: some View {
        List {
            Button("Show") {
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


