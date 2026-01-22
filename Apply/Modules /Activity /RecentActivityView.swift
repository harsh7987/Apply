//
//  RecentActivityView.swift
//  Apply
//
//  Created by Pranjal Verma on 12/01/26.
//

import SwiftUI
import SwiftData

struct RecentActivityView: View {
    @Query(filter: #Predicate<JobApplication> { $0.status != "Draft" })
    private var allApplications: [JobApplication]
    
    @StateObject private var navManager = AppNavigationManager.shared
    @State private var selectedJob: JobApplication? = nil
    
    @Environment(\.modelContext) var modelContext
    
    var finalSortedList: [JobApplication] {
            let now = Date()
            
            // A. Isolate the "Red" items
            let overdueApps = allApplications.filter { $0.followUpDate < now }
            // Sort them by who is MOST overdue
            let sortedOverdue = overdueApps.sorted { $0.followUpDate < $1.followUpDate }
            
            // B. Isolate the "Normal" items
            let normalApps = allApplications.filter { $0.followUpDate >= now }
            // Sort them by NEWEST applied (Stack Order)
            let sortedNormal = normalApps.sorted { $0.appliedDate > $1.appliedDate }
            
            // C. Glue them: Red on Top, Stack on Bottom
            return sortedOverdue + sortedNormal
        }
    
    
    var body: some View {
            List {
                if finalSortedList.isEmpty {
                    ContentUnavailableView(
                        "No Applications Yet",
                        systemImage: "envelope.open.badge.clock",
                        description: Text("Your applied jobs will appear here.")
                    )
                } else {
                    ForEach(finalSortedList) { app in
                        NavigationLink(value: app) {
                            ApplicationRow(application: app)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("Recent Activity")
            .navigationDestination(for: JobApplication.self) { app in
                ApplicationDetailView(application: app)
            }
            .navigationDestination(item: $selectedJob) { job in
                ApplicationDetailView(application: job)
            }
            .onAppear {
                checkForPendingJob()
            }
            .onChange(of: navManager.pendingJobID) { oldValue, newValue in
                if newValue != nil {
                    checkForPendingJob()
                }
            }
    }
    
    func checkForPendingJob() {
        if let pendingID = navManager.pendingJobID {
            if let job = allApplications.first(where: { $0.id.uuidString == pendingID }) {
                self.selectedJob = job
                
                navManager.pendingJobID = nil
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            let app = allApplications[index]
            NotificationManager.shared.cancelFollowUp(for: app)
            modelContext.delete(app)
        }
    }
}

struct ApplicationRow: View {
    let application: JobApplication
    
    var isOverdue: Bool {
        application.followUpDate < Date()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(application.generatedSubject)
                .font(.headline)
                .lineLimit(1)
            
            HStack {
                Text(application.companyName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if isOverdue {
                    // 🔴 OVERDUE: Show Red Dot + Text
                    HStack(spacing: 4) {
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                        
                        Text("Follow Up")
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.red)
                    }
                    // Optional: Add a subtle background pill for better visibility
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Capsule())
                    
                } else {
                    Text(application.appliedDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    RecentActivityView()
}
