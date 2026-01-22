//
//  DataModels.swift
//  Apply
//
//  Created by Pranjal Verma on 06/01/26.
//

import Foundation
import SwiftData

// 1. The user identity
@Model
class UserProfile {
    var name: String
    var phoneNumber: String
    var experience: String
    var skills: String
    var email: String
    
    var lastUpdated: Date
    
    init(name: String = "", email: String = "", phoneNumber: String = "", experience: String = "", skills: String = "") {
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.experience = experience
        self.skills = skills
        self.lastUpdated = Date()
    }
}

// 2. Job history
// when every time you click on generate we save on of these.
enum ApplicationMethod: String, Codable {
    case aiGenerated
    case manualEmail
}

@Model
class JobApplication {
    var id: UUID
    var companyName: String
    var jobTitle: String
    var jobDescription: String
    var hrEmail: String?
    var url: String
    
    var generatedSubject: String
    var generatedBody: String
    var applicationMethod: ApplicationMethod = ApplicationMethod.aiGenerated // Default
    
    
    var appliedDate: Date
    var followUpDate: Date
    var isFollowUpSent: Bool
    var status: String
    var followUpCount: Int = 0
    
    var asScrapedJob: ScrapedJob {
            ScrapedJob(
                title: jobTitle,
                cleanDescription: jobDescription,
                rawDescription: jobDescription, // We use clean as fallback
                hrEmail: hrEmail,
                url: url
            )
        }

    // 💡 The Init now only asks for what we DON'T know yet.
    // Everything else (Dates, Status) is set automatically inside.
    init(
        companyName: String,
        jobTitle: String,
        jobDescription: String,
        hrEmail: String? = nil,
        generatedSubject: String,
        generatedBody: String,
        url: String,
        status: String = "Sent",
        applicationMethod: ApplicationMethod = .aiGenerated
    ) {
        self.id = UUID()
        self.companyName = companyName
        self.jobTitle = jobTitle
        self.jobDescription = jobDescription
        self.hrEmail = hrEmail
        self.generatedSubject = generatedSubject
        self.generatedBody = generatedBody
        self.url = url
        self.applicationMethod = applicationMethod
        
        // Auto-set the logic here
        let now = Date()
        self.appliedDate = now
        self.status = status
        self.isFollowUpSent = false
        self.followUpCount = 0
        
        // ⏰ 7 Days Later// 🧪 TEST MODE: 15 Seconds
          self.followUpDate = Calendar.current.date(byAdding: .day, value: 7, to: now) ?? now.addingTimeInterval(86400 * 7)
        //self.followUpDate = Calendar.current.date(byAdding: .second, value: 15, to: now) ?? now.addingTimeInterval(15)
    }
}

extension JobApplication {
    func markFollowUpSent(context: ModelContext) {
        // 1. Cancel the OLD notification (So they don't get double pinged)
        NotificationManager.shared.cancelFollowUp(for: self)
        
        // 2. Update Counts
        self.isFollowUpSent = true
        self.followUpCount += 1
        self.status = "Followed Up (\(self.followUpCount)x)"
        
        // 3. Reset the Timer (7 Days from NOW)
        // This instantly pushes it to the bottom of the list (Green Zone)
        self.followUpDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        
        // 4. Schedule NEW Notification
        if self.followUpCount < 3 { // Stop after 3 tries (Anti-Spam)
            NotificationManager.shared.scheduleFollowUp(for: self)
        }
        
        // 5. Save
        try? context.save()
    }
}

// User Default Letter
@Model
class UserTemplate {
    var id: UUID
    var title: String      // e.g. "Standard Pitch"
    var subject: String    // The email subject
    var body: String       // The email body
    var isDefault: Bool    // Should this one be pre-selected?
    
    init(title: String, subject: String, body: String, isDefault: Bool) {
        self.id = UUID()
        self.title = title
        self.subject = subject
        self.body = body
        self.isDefault = isDefault
    }
}
