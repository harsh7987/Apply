//
//  DetailDefaultListView.swift
//  Apply
//
//  Created by Pranjal Verma on 15/01/26.
//

import SwiftUI
import SwiftData

struct DetailDefaultListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserTemplate.title) private var templates: [UserTemplate]
    
    var body: some View {
        List {
            ForEach(templates) { template in
                NavigationLink(destination: SetDefaultView(template: template)) {
                    VStack(alignment: .leading) {
                        Text(template.title)
                            .font(.headline)
                        Text(template.subject)
                            .font(.subheadline)
                            .lineLimit(1)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete(perform: deleteTemplates)
        }
        .navigationTitle("My Templates")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: SetDefaultView()) {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    private func deleteTemplates(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(templates[index])
        }
    }
}

#Preview {
    DetailDefaultListView()
}
