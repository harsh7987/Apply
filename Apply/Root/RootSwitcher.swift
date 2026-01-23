//
//  RootSwitcher.swift
//  Apply
//
//  Created by Pranjal Verma on 20/01/26.
//

import SwiftUI
import SwiftData

struct RootSwitcher: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        if !hasCompletedOnboarding {
            OnboardingView {
                // 3. Pass a "Finish Action" to the view
                withAnimation {
                    hasCompletedOnboarding = true
                }
            }
        } else {
            ContentView()
        }
    }
}
