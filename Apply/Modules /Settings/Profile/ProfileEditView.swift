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
    @Environment(\.colorScheme) var colorScheme
    
    // 1. DATA CONNECTION
    @Bindable var user: UserProfile
    var isOnboarding: Bool
    var onSave: () -> Void = {}
    
    // 2. LOCAL UI STATE (Helpers for the UI interactions)
    @State private var skillsList: [String] = []
    @State private var newSkillInput: String = ""
    @State private var experienceValue: Double = 0.0 // Slider helper
    
    var body: some View {
        ZStack {
            // A. BACKGROUND (The Slate)
            if colorScheme == .dark {
                Color(hex: "080808").ignoresSafeArea() // Deep Matte Black
            } else {
                Color(hex: "F2F2F7").ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                // 1. HEADER (Minimalist)
                HStack {
                    Text("PROFILE CONFIG")
                        .font(.subheadline.bold())
                        .tracking(2)
                        .foregroundStyle(.gray)
                    
                    Spacer()
                    
                    Button(isOnboarding ? "Continue" : "Save") {
                        saveAndDismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(isOnboarding ? .green : (colorScheme == .dark ? .white : .black))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Material.bar)
                
                ScrollView {
                    VStack(spacing: 32) {
                        
                        // 2. THE ARCHITECT AVATAR
                        HStack(spacing: 20) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(Color(hex: "1C1C1E"))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                
                                Text(getInitials(from: user.name))
                                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                                    .foregroundStyle(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("EDITING PROFILE")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.gray)
                                    .tracking(1)
                                
                                Text(user.name.isEmpty ? "Your Name" : user.name)
                                    .font(.title3.bold())
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                
                                Text(user.email.isEmpty ? "" : user.experience)
                                    .font(.subheadline)
                                    .foregroundStyle(.gray)
                                    .lineLimit(1)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        // 3. PRECISION DATA FORM
                        VStack(alignment: .leading, spacing: 8) {
                            SectionTitle(title: "CONTACT_DATA")
                            
                            VStack(spacing: 0) {
                                ArchitectRow(icon: "person", label: "FULL NAME", text: $user.name)
                                Divider().padding(.leading, 50).opacity(0.2)
                                ArchitectRow(icon: "envelope", label: "EMAIL ID", text: $user.email)
                                Divider().padding(.leading, 50).opacity(0.2)
                                ArchitectRow(icon: "phone", label: "MOBILE", text: $user.phoneNumber)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(colorScheme == .dark ? Color(hex: "1C1C1E") : .white)
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // 4. EXPERIENCE RULER
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                SectionTitle(title: "EXPERIENCE_LEVEL")
                                Spacer()
                                Text(String(format: "%.1f YRS", experienceValue))
                                    .font(.system(.callout, design: .monospaced))
                                    .fontWeight(.bold)
                                    .foregroundStyle(colorScheme == .dark ? .black : .white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(colorScheme == .dark ? .gray : .black.opacity(0.8))
                                    .cornerRadius(6)
                            }
                            
                            VStack(spacing: 10) {
                                Slider(value: $experienceValue, in: 0...30, step: 0.5)
                                    .tint(colorScheme == .dark ? .white : .black)
                                
                                // Ruler Ticks
                                HStack {
                                    ForEach(0..<6) { i in
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.5))
                                            .frame(width: 1, height: i % 5 == 0 ? 10 : 5)
                                        if i != 5 { Spacer() }
                                    }
                                }
                                .padding(.horizontal, 10)
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(colorScheme == .dark ? Color(hex: "1C1C1E") : .white)
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // 5. TECH SPEC TAGS (The Skills Engine)
                        VStack(alignment: .leading, spacing: 12) {
                            SectionTitle(title: "TECHNICAL_SPECIFICATIONS")
                            
                            // Input Area
                            HStack {
                                Image(systemName: "terminal.fill")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                
                                TextField("Add Skill (e.g. SwiftUI)...", text: $newSkillInput)
                                    .font(.system(.body, design: .monospaced))
                                    .submitLabel(.done)
                                    .onSubmit(addSkill)
                                
                                Button(action: addSkill) {
                                    Image(systemName: "plus")
                                        .fontWeight(.bold)
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            
                            // The Matte Tags Flow Layout
                            FlowLayout(spacing: 8, lineSpacing: 10) {
                                ForEach(skillsList, id: \.self) { skill in
                                    MatteTag(text: skill) {
                                        removeSkill(skill)
                                    }
                                    .frame(maxWidth: UIScreen.main.bounds.width - 60, alignment: .leading)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Color.clear.frame(height: 100) // Bottom Padding
                    }
                }
            }
        }
        .onAppear {
            initializeData()
        }
    }
    
    // MARK: - Logic Functions
    
    func initializeData() {
        // 1. Parse Skills String -> Array
        let items = user.skills.components(separatedBy: ",")
        skillsList = items.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        
        // 2. Parse Experience String -> Double (Safe conversion)
        // We clean the string (remove "years", etc) and try to get a double
        if let doubleDirect = Double(user.experience) {
            experienceValue = doubleDirect
        } else {
            // Fallback in case there is text like "6.0 YRS" from older data
            let allowedChars = CharacterSet(charactersIn: "0123456789.")
            let cleanedExp = user.experience.components(separatedBy: allowedChars.inverted).joined()
            if let doubleExp = Double(cleanedExp) {
                experienceValue = doubleExp
            }
        }
    }
    
    func saveAndDismiss() {
        // 1. Sync Array -> Skills String
        user.skills = skillsList.joined(separator: ", ")
        
        // 2. Sync Double -> Experience String
        // We format it nicely (e.g., "4.5 Years")
        user.experience = String(format: "%.1f", experienceValue)
        
        // 3. Save Context
        try? modelContext.save()
        
        // 4. Handle Dismissal Logic
        dismiss()
        
        if isOnboarding {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onSave()
            }
        } else {
            onSave()
        }
    }
    
    func addSkill() {
        guard !newSkillInput.isEmpty else { return }
        // Prevent duplicates
        if !skillsList.contains(where: { $0.caseInsensitiveCompare(newSkillInput) == .orderedSame }) {
            withAnimation {
                skillsList.append(newSkillInput)
                newSkillInput = ""
            }
        } else {
            newSkillInput = "" // Clear duplicate input
        }
    }
    
    func removeSkill(_ skill: String) {
        withAnimation {
            skillsList.removeAll { $0 == skill }
        }
    }
    
    func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        if let first = components.first?.first, let last = components.last?.first {
            return "\(first)\(last)".uppercased()
        }
        return name.prefix(2).uppercased()
    }
}

// MARK: - Sub Components

struct MatteTag: View {
    let text: String
    let onClose: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 8) {
            Text(text)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.bold)
                .foregroundStyle(colorScheme == .dark ? .white : .black)
            
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.gray)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(colorScheme == .dark ? Color(hex: "2C2C2E") : Color(hex: "E5E5EA"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct ArchitectRow: View {
    let icon: String
    let label: String
    @Binding var text: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.gray)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.gray.opacity(0.7))
                    .tracking(1)
                
                TextField("Tap to enter...", text: $text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
            }
        }
        .padding(16)
    }
}

struct SectionTitle: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.caption.bold())
            .foregroundStyle(.gray)
            .tracking(1.5)
            .padding(.leading, 4)
    }
}

// Flow Layout Logic
// The Modern Flow Layout using iOS 16 Layout Protocol
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let boundsWidth = proposal.width ?? UIScreen.main.bounds.width
        
        // 2. Calculate the flow
        let result = FlowResult(in: boundsWidth, subviews: subviews, spacing: spacing, lineSpacing: lineSpacing)
        
        // 3. 🔒 STRICT BOUNDARY: Never return a width larger than the allowed bounds!
        return CGSize(width: boundsWidth, height: result.size.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
            let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing, lineSpacing: lineSpacing)
            
            for line in result.lines {
                var x = bounds.minX
                let y = bounds.minY + line.yOffset
                
                for view in line.views {
                    view.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                    x += view.dimensions(in: .unspecified).width + spacing
                }
            }
        }
    
    // The clean math engine that calculates rows
    struct FlowResult {
        var lines: [Line] = []
        var size: CGSize = .zero
        
        struct Line {
            var views: [LayoutSubview]
            var yOffset: CGFloat
            var height: CGFloat
        }
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat, lineSpacing: CGFloat) {
            var currentLineViews: [LayoutSubview] = []
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var currentLineHeight: CGFloat = 0
            var maxX: CGFloat = 0
            
            for subview in subviews {
                let dim = subview.dimensions(in: .unspecified)
                
                // If it exceeds the max width, push to the next line
                if currentX + dim.width > maxWidth, !currentLineViews.isEmpty {
                    lines.append(Line(views: currentLineViews, yOffset: currentY, height: currentLineHeight))
                    currentY += currentLineHeight + lineSpacing
                    currentX = 0
                    currentLineHeight = 0
                    currentLineViews = []
                }
                
                currentLineViews.append(subview)
                currentX += dim.width + spacing
                currentLineHeight = max(currentLineHeight, dim.height)
                maxX = max(maxX, currentX - spacing)
            }
            
            // Add the final line
            if !currentLineViews.isEmpty {
                lines.append(Line(views: currentLineViews, yOffset: currentY, height: currentLineHeight))
                currentY += currentLineHeight
            }
            
            size = CGSize(width: maxX, height: currentY)
        }
    }
}

#Preview {
    ProfileEditView(
        user: UserProfile(
            name: "Harsh",
            email: "Harsh",
            phoneNumber: "123",
            experience: "4",
            skills: "IOS, switf, concurrency, ARC, CI/CD PipeLine, Multithreading, multiproccesing, MVVM, MVC, UIKit, SwiftUI, Data Structure and Algorithm, Experince in GCD (Grand Central Dispatch) and Operations, Async/Await, Project management: Jira, Profiling and optimizing app performance"
        ),
        isOnboarding: true
    )
}
