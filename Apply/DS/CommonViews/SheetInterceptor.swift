//
//  SheetInterceptor.swift
//  Apply
//
//  Created by Pranjal Verma on 20/01/26.
//

import SwiftUI

// 1. The Logic Structure
struct SheetInterceptor: ViewModifier {
    @Binding var showAlert: Bool
    
    // We track the sheet's current "height"
    @State private var currentDetent: PresentationDetent = .large

    func body(content: Content) -> some View {
        content
            // 2. The Trap: We set two sizes.
            // .large (Normal) and .fraction(0.99) (The invisible line)
            .presentationDetents([.large, .fraction(0.99)], selection: $currentDetent)
            
            // 3. The Trigger: Watch for changes
            .onChange(of: currentDetent) { oldValue, newValue in
                // If the user pulled down to the "Trap" line...
                if newValue == .fraction(0.99) {
                    // A. Bounce back up immediately
                    currentDetent = .large
                    // B. Show the "Are you sure?" alert
                    showAlert = true
                }
            }
            // 4. Disable standard dismiss so they can't bypass us
            .interactiveDismissDisabled()
    }
}

// 5. The Helper Extension (So you can type .interceptDismiss...)
extension View {
    func interceptDismiss(showAlert: Binding<Bool>) -> some View {
        self.modifier(SheetInterceptor(showAlert: showAlert))
    }
}
