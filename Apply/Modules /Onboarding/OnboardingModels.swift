//
//  OnboardingUISample.swift
//  Apply
//
//  Created by Pranjal Verma on 27/12/25.
//

import Foundation
import SwiftUI

enum OnboardingItemType {
    case email, resume, coverLetter
}

struct ShowData {
    
    
}

struct OnboardingItem: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subHeading: String
    let type: OnboardingItemType
}
