//
//  StatView.swift
//  Apply
//
//  Created by Pranjal Verma on 30/12/25.
//

import SwiftUI
import SwiftData

struct StatsViews: View {
    @Query(filter: #Predicate<JobApplication> { $0.status != "Draft" })
    private var activeApplications: [JobApplication]
    
    // 🔄 2. COMPUTED LOGIC (Live Counts)
    
    var applicationsSentCount: Int {
        // Simple: Just the total number of non-draft apps
        activeApplications.count
    }
    
    var followUpsDueCount: Int {
        let now = Date()
        return activeApplications.filter { app in
            // Condition A: Is the date in the past?
            let isOverdue = app.followUpDate < now
            
            // Condition B: Have we annoyed them less than 3 times?
            // 🛑 THIS FIXES YOUR EDGE CASE.
            // If count is 3, this returns false, and it won't show in the badge.
            let isActionable = app.followUpCount < 3
            
            // Condition C: Is the app still alive? (Optional)
            // You might not want to follow up if "Rejected" or "Hired"
            let isActive = app.status != "Rejected" && app.status != "Hired"
            
            return isOverdue && isActionable && isActive
        }.count
    }
    var stats: [StatModel] = [
        StatModel(icon: "paperplane.fill", value: 24, title: "Applications Sent"),
        StatModel(icon: "clock.fill", value: 3, title: "Follow-ups Due"),
        StatModel(icon: "phone.fill", value: 1, title: "Callbacks")
    ]
    var body: some View {
        HStack(spacing: 12) {
                    // CARD 1: SENT
                    StatsCard(
                        icon: "paperplane.fill",
                        count: applicationsSentCount,
                        label: "Applications\nSent"
                    )
                    
                    // CARD 2: DUE
                    StatsCard(
                        icon: "clock.fill",
                        count: followUpsDueCount,
                        label: "Follow-ups\nDue",
                        isUrgent: followUpsDueCount > 0 // Turn yellow/red if work needed
                    )
                    
                    // CARD 3: CALLBACKS (Optional placeholder)
                    StatsCard(
                        icon: "phone.fill",
                        count: 1,
                        label: "Callbacks\nRecieved"
                    )
                }
                .padding()
    }
}

struct StatsCard: View {
    var statDetail: StatModel
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Image(systemName: statDetail.icon)
                .font(.title2)
                .foregroundStyle(.gray)
            Text("\(statDetail.value)")
                .largeBoldTitle2()
            Text(statDetail.title)
                .obSubHeadline().bold()
        }
        .frame(width: 130, height: 120, alignment: .topLeading).padding()
        .glossyCardBg(radius: 20)
    }
}

#Preview {
    let obj = StatModel(icon: "paperplane.fill", value: 24, title: "Applications\nSent")
    StatsCard(statDetail: obj)
    
//    StatsViews()
}
