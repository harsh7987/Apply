//
//  NotificationManager.swift
//  Apply
//
//  Created by Pranjal Verma on 12/01/26.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func scheduleFollowUp(for application: JobApplication) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Follow Up! 📧"
        content.body = "Check in on your application for \(application.companyName == "Unknown Company" ? application.generatedSubject : application.companyName)."
        content.sound = .default
        
        content.userInfo = ["jobID": application.id.uuidString]
        
        // 🧪 TEST TRIGGER: 10 seconds from now
         let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 604800, repeats: false)
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: application.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if error == nil { print("🧪 TEST: Notification scheduled for 10 seconds from now!") }
        }
    }
    
    func cancelFollowUp(for application: JobApplication) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [application.id.uuidString])
            print("🔕 Notification cancelled for \(application.companyName)")
        }
}
