//
//  OnboardingViewModel.swift
//  Apply
//
//  Created by Pranjal Verma on 27/12/25.
//

import SwiftUI

@Observable
class OnboardingViewModel {
    
    var isExtensionEnabled = false {
        didSet {
            // add func logic
            print("IsExtension Enabled")
        }
    }
    
    func performAction(data: OnboardingItemType) {
        switch data {
        case .coverLetter:
            print("latter ")
        case .email:
            print("Email")
        case .resume:
            print("Resume")
        }
    }
    
    func saveAllData() {
        print("Save Data... ")
    }
    
}

