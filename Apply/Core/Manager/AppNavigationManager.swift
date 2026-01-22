//
//  AppNavigationManager.swift
//  Apply
//
//  Created by Pranjal Verma on 12/01/26.
//

import Foundation
import Combine

import SwiftUI

class AppNavigationManager: ObservableObject {
    static let shared = AppNavigationManager()
    
    // We use @Published so the UI "listens" to changes here
    @Published var selectedTab: Int = 0
    @Published var pendingJobID: String? = nil
    
    // Helper to switch to History tab (Index 2)
    func goToHistory(jobID: String) {
        self.selectedTab = 2
        self.pendingJobID = jobID
    }
}
