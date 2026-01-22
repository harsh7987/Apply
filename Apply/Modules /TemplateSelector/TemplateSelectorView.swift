//
//  TemplateSelector.swift
//  Apply
//
//  Created by Pranjal Verma on 16/01/26.
//

import SwiftUI
import SwiftData

struct TemplateSelectorView: View {
    @Query(sort: \UserTemplate.title) private var templates: [UserTemplate]
    @State private var selectedTemplate: UserTemplate?
    
    // Callbacks to tell the parent what happened
    var onSelectAI: () -> Void
    var onSelectTemplate: (UserTemplate) -> Void
    var onCancel: () -> Void

    var body: some View {
        ZStack {
            // 1. The Dimmed Background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            // 2. The Modal Box
            VStack(spacing: 0) {
                Text("Choose Application Method")
                    .font(.headline)
                    .padding()

                Text("Select how you'd like to draft this application.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)

                // 3. The List of Options
                ScrollView {
                    VStack(spacing: 1) {
                        // Special Option: AI Magic
                        Button(action: {
                            FeedbackManager.shared.impact(.light)
                            onSelectAI()
                        }) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(.purple)
                                Text("AI Magic (Custom Cover Letter)")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                        }
                        .buttonStyle(.plain)

                        Divider()

                        // Manual Templates
                        ForEach(templates) { template in
                            Button(action: {
                                FeedbackManager.shared.impact(.light)
                                selectedTemplate = template
                            }) {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(.blue)
                                    Text(template.title)
                                    Spacer()
                                    if selectedTemplate?.id == template.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.blue)
                                    }
                                }
                                .padding()
                                .background(selectedTemplate?.id == template.id ? Color.blue.opacity(0.1) : Color(uiColor: .secondarySystemGroupedBackground))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .background(Color(uiColor: .systemGroupedBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .frame(maxHeight: 250)

                // 4. Action Buttons
                HStack(spacing: 20) {
                    Button("Cancel") {
                        FeedbackManager.shared.trigger(.error)
                        onCancel()
                    }
                        .foregroundStyle(.red)
                    
                    Button("Confirm Selection") {
                        if let template = selectedTemplate {
                            FeedbackManager.shared.impact(.medium)
                            onSelectTemplate(template)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedTemplate == nil)
                }
                .padding()
            }
            .frame(width: 320)
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(20)
            .shadow(radius: 20)
        }
    }
}

#Preview {
  //  TemplateSelectorView(onSelectAI: <#() -> Void#>, onSelectTemplate: <#(UserTemplate) -> Void#>, onCancel: <#() -> Void#>)
}
