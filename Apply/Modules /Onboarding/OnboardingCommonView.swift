//
//  OnboardingCommonView.swift
//  Apply
//
//  Created by Pranjal Verma on 27/12/25.
//

import SwiftUI

struct MyraDataCartridge: View {
    let title: String
    let subtitle: String
    
    // 1. ACCEPT YOUR EXISTING LOGIC DIRECTLY
    var isLoading: Bool
    var isComplete: Bool
    
    // 2. The Trigger Action
    var action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @State private var rotation: Double = 0
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // A. THE RING INDICATOR
                ZStack {
                    // Background Circle
                    Circle()
                        .fill(isComplete ? (colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05)) : Color.clear)
                        .frame(width: 56, height: 56)
                    
                    if isLoading {
                        // SPINNING RING
                        Circle()
                            .stroke(
                                AngularGradient(gradient: Gradient(colors: [.cyan, .purple, .clear]), center: .center),
                                lineWidth: 3
                            )
                            .frame(width: 56, height: 56)
                            .rotationEffect(.degrees(rotation))
                            .onAppear {
                                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                    rotation = 360
                                }
                            }
                    } else if isComplete {
                        // LOCKED RING
                        Circle()
                            .stroke(
                                AngularGradient(gradient: Gradient(colors: [.cyan, .purple, .blue, .cyan]), center: .center),
                                lineWidth: 3
                            )
                            .frame(width: 56, height: 56)
                            .shadow(color: .cyan.opacity(0.5), radius: 8)
                        
                        // CHECKMARK
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        // EMPTY STATE (DOTTED)
                        Circle()
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [4]))
                            .foregroundStyle(Color.gray.opacity(0.4))
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "arrow.up")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.gray.opacity(0.6))
                    }
                }
                
                // B. TEXT INFO
                VStack(alignment: .leading, spacing: 4) {
                    Text(isLoading ? "Analyzing..." : (isComplete ? title + " Loaded" : title))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .contentTransition(.numericText())
                    
                    Text(isComplete ? "Data Verified" : subtitle)
                        .font(.caption)
                        .foregroundStyle(
                            isComplete
                            ? (colorScheme == .dark ? Color(hex: "00FF9D") : Color.green)
                            : Color.gray.opacity(0.5)
                        )
                }
                
                Spacer()
                
                // C. ARROW INDICATOR
                if !isLoading && !isComplete {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.gray.opacity(0.3))
                }
            }
            .padding(18)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(colorScheme == .dark ? Color.black.opacity(0.3) : .white)
                    
                    if isComplete {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(LinearGradient(colors: [Color.cyan.opacity(0.05), Color.purple.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        isComplete
                        ? AnyShapeStyle(LinearGradient(colors: [.cyan.opacity(0.6), .purple.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        : AnyShapeStyle(Color.gray.opacity(0.1)),
                        lineWidth: isComplete ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .allowsHitTesting(!isLoading && !isComplete) // Lock button if busy or done
    }
}

#Preview {
    MyraDataCartridge(title: "Resume Core", subtitle: "PDF / DocX", isLoading: false, isComplete: false, action: {})
}
