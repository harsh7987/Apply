//
//  OnboardingUISample.swift
//  Apply
//
//  Created by Pranjal Verma on 27/12/25.
//

import Foundation
import SwiftUI

enum OnboardingItemType {
    case email, resume, coverLetter, exTension
}

struct ShowData {
    var uiSampleData: [SampleData] = []
    var isMyExtensionEnable: Bool = false
    
    var email = SampleData(imageName: "envelope.fill", title: "Connect Email", subHeading: "Email,Outlook,iCloud", type: .email)
    var resume = SampleData(imageName: "text.document.fill", title: "Upload Resume", subHeading: "PDF or DocX", type: .resume)
    static var latter = SampleData(imageName: "long.text.page.and.pencil.fill", title: "Cover Latter", subHeading: "Optional for tone matching", type: .coverLetter)
    var exTension = SampleData(imageName: "square.and.arrow.up.circle", title: "Enable Extension", subHeading: "Save jobs from Safari", type: .exTension)
    
    mutating func loadData() {
        uiSampleData.append(email)
        uiSampleData.append(resume)
        uiSampleData.append(ShowData.latter)
        uiSampleData.append(exTension)
    }
    
}

struct SampleData: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subHeading: String
    let type: OnboardingItemType
}
