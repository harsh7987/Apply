//
//  RootSwitcher.swift
//  Apply
//
//  Created by Pranjal Verma on 20/01/26.
//

import SwiftUI
import SwiftData

struct RootSwitcher: View {
    @Query private var users: [UserProfile]
    
    var body: some View {
        if users.isEmpty {
            OnboardingView()
        } else {
            ContentView()
        }
    }
}
