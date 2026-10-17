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
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView {
                    withAnimation {
                        // 1. Grant the tokens RIGHT HERE, after they finish onboarding
                        CreditManager.shared.grantInitialTokens(context: modelContext)
                        
                        // 2. Dismiss onboarding
                        hasCompletedOnboarding = true
                    }
                }
            } else {
                ContentView()
            }
        }
        .onAppear {
            // Just connect and listen on launch, don't create anything yet.
            CreditManager.shared.connectToCloud(context: modelContext)
        }
    }
}
