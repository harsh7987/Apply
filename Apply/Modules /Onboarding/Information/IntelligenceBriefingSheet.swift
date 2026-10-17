//
//  IntelligenceBriefingSheet.swift
//  Apply
//
//  Created by Pranjal Verma on 05/02/26.
//

import SwiftUI

// --- NEW COMPONENT: THE INTELLIGENCE SHEET ---
struct IntelligenceBriefingSheet: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
            ZStack {
                // Background
                if colorScheme == .dark {
                    Color(hex: "101010").ignoresSafeArea()
                } else {
                    Color(hex: "F2F2F7").ignoresSafeArea()
                }
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Title
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "cpu.fill")
                                .foregroundStyle(.cyan)
                            Text("AI & PRIVACY") // Replaced "DATA ARCHITECTURE"
                                .font(.caption.bold())
                                .foregroundStyle(.cyan)
                                .tracking(1)
                        }
                        Text("How our AI works for you") // Replaced "Neural Engine"
                            .font(.title3.bold())
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    }
                    .padding(.top, 20)
                    
                    // Modules
                    VStack(spacing: 16) {
                        // Module 1: Resume
                        BriefingRow(
                            icon: "doc.text.viewfinder",
                            color: .blue,
                            title: "Profile Analysis", // Replaced "Context Engine"
                            desc: "Maps your specific achievements to job descriptions for higher match rates."
                        )
                        
                        // Module 2: Cover Letter
                        BriefingRow(
                            icon: "waveform.path.ecg",
                            color: .purple,
                            title: "Voice Personalization", // Replaced "Tone Matrix"
                            desc: "Analyzes your writing style to ensure generated emails sound exactly like you."
                        )
                        
                        // Module 3: Security
                        BriefingRow(
                            icon: "lock.shield.fill",
                            color: .green,
                            title: "Privacy First", // Replaced "Encrypted Core"
                            desc: "Your data is encrypted, processed locally, and never shared with third parties." // Removed "secure shards"
                        )
                    }
                    
                    Spacer()
                    
                    // The Strategic Footer
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundStyle(.green)
                        Text("Your data is strictly private and secure.") // Sounds much more confident
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 10)
                }
                .padding(24)
            }
        }
}

// --- SUB-COMPONENT: BRIEFING ROW ---
struct BriefingRow: View {
    let icon: String
    let color: Color
    let title: String
    let desc: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                
                Text(desc)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(hex: "1C1C1E") : .white)
        )
        // Subtle Border
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.05), lineWidth: 1)
        )
    }
}

#Preview {
    IntelligenceBriefingSheet()
}
