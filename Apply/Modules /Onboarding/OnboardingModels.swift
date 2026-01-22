//
//  OnboardingModels.swift
//  Apply
//
//  Created by Pranjal Verma on 27/12/25.
//

import Foundation
import SwiftUI

enum OnboardingItemType {
//    case email
    case resume, coverLetter
}

struct OnboardingItem: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subHeading: String
    let type: OnboardingItemType
}
