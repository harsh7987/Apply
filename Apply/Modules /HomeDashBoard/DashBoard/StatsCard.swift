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
        
    var applicationsSentCount: Int {
        // Simple: Just the total number of non-draft apps
        activeApplications.count
    }
    
    var followUpsDueCount: Int {
        let now = Date()
        return activeApplications.filter { app in
            // Condition A: Is the date in the past?
            let isOverdue = app.followUpDate < now
          
            let isActionable = app.followUpCount < 3
        
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
        ScrollView(.horizontal, showsIndicators: false) {
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
}

struct StatsCard: View {
    let icon: String
    let count: Int
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.gray)
            Text("\(count)")
                .largeBoldTitle2()
            Text(label)
                .obSubHeadline().bold()
        }
        .frame(width: 130, height: 120, alignment: .topLeading).padding()
        .glossyCardBg(radius: 20)
    }
}

#Preview {
    let obj = StatModel(icon: "paperplane.fill", value: 24, title: "Applications\nSent")
    StatsCard(icon: "paperplane.fill", count: 24, label: "Applications\nSent")
    
//    StatsViews()
}
