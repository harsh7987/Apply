//
//  ApplyApp.swift
//  Apply
//
//  Created by Pranjal Verma on 27/12/25.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct ApplyApp: App {
    @UIApplicationDelegateAdaptor(NotificationDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RootSwitcher()
        }
        .modelContainer(for: [UserProfile.self, JobApplication.self, UserTemplate.self])
    }
}

class NotificationDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    // 1. System Setup (Runs automatically)
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // 2. Banner while app is OPEN
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    // 3. Handle TAP (Deep Linking)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        if let jobIDString = userInfo["jobID"] as? String {
            DispatchQueue.main.async {
                AppNavigationManager.shared.goToHistory(jobID: jobIDString)
            }
        }
        completionHandler()
    }
}
