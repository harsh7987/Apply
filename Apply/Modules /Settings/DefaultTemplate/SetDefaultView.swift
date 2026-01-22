//
//  SetDefaultView.swift
//  Apply
//
//  Created by Pranjal Verma on 15/01/26.
//

import SwiftUI
import SwiftData

struct SetDefaultView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allTemplates: [UserTemplate] // Need this to reset other defaults
    
    @State private var title: String = ""
    @State private var subject: String = ""
    @State private var bodyText: String = ""
    @State private var isDefault: Bool = false // 👈 New State
    
    let template: UserTemplate?
    
    init(template: UserTemplate? = nil) {
        self.template = template
        _title = State(initialValue: template?.title ?? "")
        _subject = State(initialValue: template?.subject ?? "")
        _bodyText = State(initialValue: template?.body ?? "")
        _isDefault = State(initialValue: template?.isDefault ?? false) // 👈 Initialize
    }
    
    var body: some View {
        Form {
            Section("Template Identity") {
                TextField("E.g., Standard Pitch", text: $title)
                // 🟢 The Pre-selection Toggle
                Toggle("Set as Primary Default", isOn: $isDefault)
            }
            
            Section("Email Content") {
                TextField("Subject Line", text: $subject)
                TextEditor(text: $bodyText)
                    .frame(minHeight: 200)
            }
        }
        .navigationTitle(template == nil ? "New Template" : "Edit Template")
        .toolbar {
            Button("Save") {
                save()
            }
            .disabled(title.isEmpty || bodyText.isEmpty)
        }
    }
    
    private func save() {
        // 1. If this one is the new default, clear the others first
        if isDefault {
            for otherTemplate in allTemplates {
                otherTemplate.isDefault = false
            }
        }
        
        if let template = template {
            // Update
            template.title = title
            template.subject = subject
            template.body = bodyText
            template.isDefault = isDefault
        } else {
            // Create
            let newTemplate = UserTemplate(
                title: title,
                subject: subject,
                body: bodyText,
                isDefault: isDefault // 👈 Pass it here
            )
            modelContext.insert(newTemplate)
        }
        
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    SetDefaultView()
}
