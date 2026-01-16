//
//  ProfileEditView.swift
//  Apply
//
//  Created by Pranjal Verma on 10/01/26.
//

import SwiftUI
import SwiftData

struct ProfileEditView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @Bindable var user: UserProfile
    var isOnboarding: Bool
    
    var onSave: () -> Void = {}
    
    var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.viewfinder")
                            .font(.system(size: 50))
                            .foregroundStyle(.green)
                        
                        Text("Review Your Resume Data")
                            .font(.title2).bold()
                            .multilineTextAlignment(.center)
                        
                        Text("We've extracted information from your resume.\nPlease review and edit if needed.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        CustomTextField(title: "Full Name", text: $user.name)
                        CustomTextField(title: "Email Address", text: $user.email)
                        CustomTextField(title: "Phone Number", text: $user.phoneNumber)
                        CustomTextField(title: "Years of Experience", text: $user.experience)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            VStack(alignment: .leading) {
                                Text("Skills")
                                    .font(.subheadline).bold()
                                    .foregroundStyle(.gray)
                                
                                Text("Enter skills separated by commas")
                                    .font(.caption).bold()
                                    .foregroundStyle(.gray)
                            }
                            
                            TextEditor(text: $user.skills)
                                .frame(height: 100)
                                .scrollContentBackground(.hidden)
                        }
                        .padding()
                        .background(Color(uiColor: .systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isOnboarding ? "Continue" : "Save") {
                        saveAndDismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
                }
            }
    }
    
    func saveAndDismiss() {
        try? modelContext.save()
        
        dismiss()
        
        if isOnboarding {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onSave()
            }
        } else {
            onSave()
        }
    }
}

struct CustomTextField: View {
    var title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline).bold()
                .foregroundStyle(.gray)
            
            TextField("", text: $text)
                .font(.body)
                .foregroundStyle(.primary)
                
        }
        .padding()
        .background(Color(uiColor: .systemGray6)) // The Gray Box Look
        .cornerRadius(12)
    }
}

#Preview {
    ProfileEditView(user: UserProfile(), isOnboarding: true)
}
