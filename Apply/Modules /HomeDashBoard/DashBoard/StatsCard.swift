//
//  StatView.swift
//  Apply
//
//  Created by Pranjal Verma on 30/12/25.
//

import SwiftUI
import SwiftData

struct StatsViews: View {
    @Query(filter: #Predicate<JobApplication> { $0.status != "Draft" })
    private var activeApplications: [JobApplication]
        
    var applicationsSentCount: Int {
        // Simple: Just the total number of non-draft apps
        activeApplications.count
    }
    
    var followUpsDueCount: Int {
        let now = Date()
        return activeApplications.filter { app in
            // Condition A: Is the date in the past?
            let isOverdue = app.followUpDate < now
          
            let isActionable = app.followUpCount < 3
        
            let isActive = app.status != "Rejected" && app.status != "Hired"
            
            return isOverdue && isActionable && isActive
        }.count
    }
    
    
    var body: some View {
        HStack(spacing: 16) {
            DashboardCard(
                title: "Applications\nSent",
                count: "\(applicationsSentCount)",
                icon: "paperplane.fill",
                color: .blue
            )
            
            DashboardCard(
                title: "Follow-ups\nDue",
                count: "\(followUpsDueCount)",
                icon: "clock.fill",
                color: .orange
            )
        }
        .padding(.horizontal, 24)

    }
}

struct DashboardCard: View {
    var title: String
    var count: String
    var icon: String
    var color: Color // Pass .blue or .orange
    
    @State private var animate = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // --- TOP ROW: Icon & Count ---
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    // Icon logic: White in Dark Mode, Color in Light Mode
                    .foregroundColor(colorScheme == .dark ? .white : color)
                    .shadow(color: (colorScheme == .dark ? color : color).opacity(0.6), radius: 8, x: 0, y: 0)
                
                Spacer()
                
                Text(count)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .white : .black.opacity(0.85))
            }
            
            // --- BOTTOM ROW: Title ---
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.6))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                // 1. DYNAMIC BASE BACKGROUND
                LinearGradient(
                    colors: getBaseColors(),
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                
                // 2. LIQUID PLASMA ANIMATION (Always Alive)
                GeometryReader { proxy in
                    ZStack {
                        // Blob 1
                        Circle()
                            .fill(getPlasmaColor1())
                            .frame(width: 200, height: 200)
                            .blur(radius: 60)
                            .offset(x: animate ? -50 : 50, y: animate ? -20 : 20)
                        
                        // Blob 2
                        Circle()
                            .fill(getPlasmaColor2())
                            .frame(width: 150, height: 150)
                            .blur(radius: 50)
                            .offset(x: animate ? 60 : -60, y: animate ? 30 : -30)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // 3. DIAMOND SHIMMER (The Fix: Always there, just invisible in Dark Mode)
                LinearGradient(
                    colors: [.clear, .white.opacity(0.6), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: 100)
                .rotationEffect(.degrees(20))
                .offset(x: animate ? 200 : -200)
                .blur(radius: 20)
                .opacity(colorScheme == .light ? 1 : 0) // <--- PERMANENT ANIMATION FIX
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        )
        .overlay(
            // 4. CHROME BEZEL
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            colorScheme == .dark ? .white.opacity(0.6) : .white,
                            colorScheme == .dark ? .white.opacity(0.05) : .white.opacity(0.4),
                            colorScheme == .dark ? .white.opacity(0.3) : .white.opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(
            color: colorScheme == .dark ? Color.black.opacity(0.5) : Color.black.opacity(0.1),
            radius: 15, x: 0, y: 10
        )
        .onAppear {
            // Because no views are ever destroyed, this runs forever without stopping
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
    
    // --- INTELLIGENT COLOR LOGIC ---
    
    func getBaseColors() -> [Color] {
        if colorScheme == .dark {
            // DARK MODE: UNIFIED TERMINAL (Black/Dark Grey)
            return [
                Color(red: 0.02, green: 0.02, blue: 0.03),
                Color(red: 0.05, green: 0.05, blue: 0.07)
            ]
        } else {
            // LIGHT MODE: SPLIT PERSONALITY (Icy vs Warm)
            if color == .blue {
                return [Color(red: 0.95, green: 0.97, blue: 0.99), Color(red: 0.85, green: 0.88, blue: 0.92)]
            } else {
                return [Color(red: 0.98, green: 0.97, blue: 0.95), Color(red: 0.90, green: 0.88, blue: 0.85)]
            }
        }
    }
    
    func getPlasmaColor1() -> Color {
        if colorScheme == .dark {
            // DARK MODE: Subtle Silver/Blue Plasma
            return Color(red: 0.7, green: 0.8, blue: 1.0).opacity(0.1)
        } else {
            // LIGHT MODE: Distinct Blue or Gold Tint
            return color == .blue ? Color(red: 0.0, green: 0.6, blue: 1.0).opacity(0.15) : Color(red: 1.0, green: 0.8, blue: 0.4).opacity(0.15)
        }
    }
    
    func getPlasmaColor2() -> Color {
        if colorScheme == .dark {
            // DARK MODE: Faint warm silver
            return Color(red: 0.9, green: 0.9, blue: 1.0).opacity(0.08)
        } else {
            // LIGHT MODE: Bright White Highlight
            return Color.white.opacity(0.8)
        }
    }
}

#Preview {
//    let obj = StatModel(icon: "paperplane.fill", value: 24, title: "Applications\nSent")
//    StatsCard(icon: "paperplane.fill", count: 24, label: "Applications\nSent")
    
    StatsViews()
}
