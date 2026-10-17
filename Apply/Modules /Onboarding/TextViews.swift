//
//  TextViews.swift
//  Apply
//
//  Created by Pranjal Verma on 28/12/25.
//

import SwiftUI

struct OBSubHeadline: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            // CHANGED: ENVELOPE ICON
            Image(systemName: "envelope.fill")
                .font(.system(size: 40))
                .foregroundStyle(
                    LinearGradient(
                        colors: colorScheme == .dark
                        ? [.white.opacity(1.3), .white.opacity(0.1)] // Dark Mode: White Ghost
                        : [Color(red: 0.0, green: 0.35, blue: 1.0).opacity(0.8), Color.black.opacity(0.4)], // Light Mode: Electric Blue Glass
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .cyan.opacity(0.5), radius: 20)
        }
        
        VStack(spacing: 8) {
            Text("Initialize Workspace")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(colorScheme == .dark ? .white : .black)
            
            Text("Upload your resume to help the AI\nlearn your unique experience.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
                .lineSpacing(4)
        }
        
    }
}


#Preview {
    OBSubHeadline()
}


