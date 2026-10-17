//
//  TemplateFrostedGlass.swift
//  CallBackTesting
//
//  Created by Pranjal Verma on 31/01/26.
//

import SwiftUI
import SwiftData


struct TemplateFrostedGlass: View {
    // 1. DATA
    @Query(sort: \UserTemplate.title) private var templates: [UserTemplate]
    @State private var selectedTemplate: UserTemplate?
    
    // 2. CALLBACKS
    var onSelectAI: () -> Void
    var onSelectTemplate: (UserTemplate) -> Void
    var onCancel: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // A. DIMMED BACKGROUND
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    FeedbackManager.shared.trigger(.error) // Optional: Haptic on cancel
                    onCancel()
                }
                // Important: Keeps the blur effect consistent
                .background(Material.ultraThin)
            
            // B. THE GLASS MODAL
            VStack(spacing: 0) {
                
                // 1. HEADER
                VStack(spacing: 6) {
                    Text("Choose Application Method")
                        .font(.headline)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    
                    Text("Select how you'd like to draft this application.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)
                .padding(.bottom, 20)
                .padding(.horizontal)
                
                // 2. THE LIST (Scrollable Area)
                ScrollView {
                    VStack(spacing: 12) {
                        
                        // OPTION A: AI MAGIC
                        Button(action: {
                            FeedbackManager.shared.impact(.light) // <--- ADDED HAPTIC
                            withAnimation(.spring(response: 0.3)) {
                                selectedTemplate = nil
                                onSelectAI()
                            }
                        }) {
                            HStack(spacing: 12) {
                                // Icon Box
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 36, height: 36)
                                        .opacity(0.2)
                                    
                                    Image(systemName: "sparkles")
                                        .foregroundStyle(LinearGradient(colors: [.purple, .cyan], startPoint: .top, endPoint: .bottom))
                                        .font(.system(size: 16, weight: .bold))
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("AI Magic")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    Text("Custom Cover Letter")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption.bold())
                                    .foregroundStyle(.purple.opacity(0.8))
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.purple.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(LinearGradient(colors: [.purple.opacity(0.5), .clear], startPoint: .leading, endPoint: .trailing), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // DIVIDER
                        HStack {
                            Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
                            Text("OR TEMPLATES")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.gray.opacity(0.6))
                            Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 1)
                        }
                        .padding(.vertical, 4)
                        
                        // OPTION B: MANUAL TEMPLATES
                        if templates.isEmpty {
                            Text("No templates found")
                                .font(.caption)
                                .foregroundStyle(.gray)
                                .padding()
                        } else {
                            ForEach(templates) { template in
                                TemplateCapsule(
                                    template: template,
                                    isSelected: selectedTemplate?.id == template.id,
                                    action: {
                                        FeedbackManager.shared.impact(.light) // <--- ADDED HAPTIC
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedTemplate = template
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
                .frame(maxHeight: 350) // Limits height so it doesn't take full screen
                
                // 3. FOOTER (Action Buttons)
                HStack(spacing: 16) {
                    // Cancel
                    Button(action: {
                        FeedbackManager.shared.trigger(.error) // <--- ADDED HAPTIC
                        onCancel()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.gray)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                    }
                    
                    // Confirm
                    Button(action: {
                        if let template = selectedTemplate {
                            FeedbackManager.shared.impact(.medium) // <--- ADDED HAPTIC
                            onSelectTemplate(template)
                        }
                    }) {
                        Text("Confirm")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.black) // Always black text on gold button
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        LinearGradient(
                                            colors: selectedTemplate != nil ? [.orange, .yellow] : [.gray.opacity(0.3), .gray.opacity(0.2)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .shadow(color: selectedTemplate != nil ? .orange.opacity(0.3) : .clear, radius: 10, x: 0, y: 5)
                    }
                    .disabled(selectedTemplate == nil)
                }
                .padding(20)
                .background(Color.black.opacity(0.05))
            }
            .frame(width: 320)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Material.thick) // The Glass Effect
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(
                            colors: colorScheme == .dark ? [.white.opacity(0.2), .clear] : [.black.opacity(0.1), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 15)
        }
        // Smooth Entry Transition
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}

// --- SUB-COMPONENT FOR TEMPLATE CAPSULES ---
struct TemplateCapsule: View {
    let template: UserTemplate
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: isSelected ? "checkmark" : "doc.text.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(isSelected ? .white : .gray)
                }
                
                // Text
                Text(template.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                
                Spacer()
                
                // Radio Indicator
                Circle()
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 18, height: 18)
                    .overlay(
                        Circle()
                            .fill(isSelected ? Color.blue : Color.clear)
                            .frame(width: 10, height: 10)
                    )
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.black.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TemplateFrostedGlass(onSelectAI: {}, onSelectTemplate: {_ in }, onCancel: {})
}
