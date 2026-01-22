//
//  DraftsView.swift
//  Apply
//
//  Created by Pranjal Verma on 14/01/26.
//

import SwiftUI
import SwiftData

struct DraftsView: View {
    @Environment(\.modelContext) private var modelContext
        
        // 🔍 Static Predicate: Only show drafts
        @Query(filter: #Predicate<JobApplication> { app in
            app.status == "Draft"
        }, sort: \.appliedDate, order: .reverse)
        private var drafts: [JobApplication]

    
    var body: some View {
            List {
                if drafts.isEmpty {
                    ContentUnavailableView("No Drafts", systemImage: "pencil.and.outline", description: Text("Saved drafts will appear here."))
                } else {
                    ForEach(drafts) { app in
                        NavigationLink(value: app) {
                            DraftRow(draft: app)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("Drafts")
            .navigationDestination(for: JobApplication.self) { app in
                    RefineEmailView(existingDraft: app)
            }
    }
    

    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(drafts[index])
        }
    }
}

struct DraftRow: View {
    let draft: JobApplication
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(draft.generatedSubject)
                .font(.headline)
                .lineLimit(1)
            Text(draft.companyName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Saved on \(draft.appliedDate.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DraftsView()
}
