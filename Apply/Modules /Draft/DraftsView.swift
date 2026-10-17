//
//  DraftsView.swift
//  Apply
//
//  Created by Pranjal Verma on 14/01/26.
//

import SwiftUI
import SwiftData

struct DraftsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    // 🔍 Static Predicate: Only show drafts
    @Query(filter: #Predicate<JobApplication> { app in
        app.status == "Draft"
    }, sort: \.appliedDate, order: .reverse)
    private var drafts: [JobApplication]
    
    @State private var selectedDraft: JobApplication? = nil
    
    
    var body: some View {
        ZStack {
            // A. BACKGROUND (Deep Void)
            if colorScheme == .dark {
                Color.black.ignoresSafeArea()
            } else {
                Color(red: 0.98, green: 0.98, blue: 0.99).ignoresSafeArea()
            }
            
            // B. CONTENT
            if drafts.isEmpty {
                ContentUnavailableView("No Drafts", systemImage: "pencil.and.outline", description: Text("Saved drafts will appear here."))
            } else {
                List {
                    // HEADER SPACER (To push content down slightly like Activity View)
                    Section {
                        HStack {
                            Text("Drafts")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                            Spacer()
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    }
                    
                    // THE DRAFT CARDS
                    ForEach(drafts) { app in
                        // 1. Wrap in Button for "Squish" Effect
                        Button(action: {
                            selectedDraft = app
                        }) {
                            // 2. Reuse the God Level Card
                            DraftGlassCard(draft: app) {
                                selectedDraft = app
                            }
                        }
                        // 3. Apply the Tactile Style
                        .buttonStyle(DraftGlassTouchStyle())
                        
                        // 4. List Styling Removal
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.bottom, 80) // Tab Bar Space
            }
        }
        // 3. NAVIGATION DESTINATION
        .navigationDestination(item: $selectedDraft) { app in
            RefineEmailView(existingDraft: app)
        }
    }
    
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(drafts[index])
            }
            try? modelContext.save()
        }
    }
}

struct DraftGlassCard: View {
    let draft: JobApplication
    var action: () -> Void
    
    @State private var animate = false
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    
    // --- LOGIC: DETERMINE STATUS & COLOR ---
    var isDraft: Bool {
        draft.status == "Draft"
    }
    
    var isOverdue: Bool {
        !isDraft && draft.followUpDate < Date()
    }
    
    var statusLabel: String {
        if isDraft { return "Draft" }
        return isOverdue ? "Follow Up" : "Applied"
    }
    
    var statusColor: Color {
        if isDraft { return .orange }
        return isOverdue ? .red : .blue
    }
    
    // Helper for relative date (e.g. "2 days ago")
    var dateLabel: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: draft.appliedDate, relativeTo: Date())
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                
                // A. COMPANY ICON (Gradient Ring)
                ZStack {
                    Circle()
                        .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.white)
                        .frame(width: 50, height: 50)
                    
                    // Company Initial
                    Text(String(draft.companyName.prefix(1)).uppercased())
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    
                    // "Ask Myra" Style Ring
                    if colorScheme == .dark {
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.0), .white.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                            .frame(width: 50, height: 50)
                    } else {
                        Circle()
                            .strokeBorder(
                                AngularGradient(
                                    gradient: Gradient(colors: [.cyan, statusColor, .purple, .cyan]),
                                    center: .center
                                ),
                                lineWidth: 1
                            )
                            .frame(width: 50, height: 50)
                    }
                }
                
                // B. INFO STACK
                VStack(alignment: .leading, spacing: 4) {
                    Text(draft.generatedSubject) // Using Subject as Title or Job Title if preferred
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .lineLimit(1)
                    
                    Text(draft.companyName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // C. STATUS & DATE
                VStack(alignment: .trailing, spacing: 8) {
                    // Neon Status Pill
                    HStack(spacing: 6) {
                        if colorScheme == .dark {
                            Circle()
                                .fill(.white.opacity(0.6))
                                .frame(width: 6, height: 6)
                                .shadow(color: .white.opacity(0.8), radius: 4)
                            
                            Text(statusLabel)
                                .font(.system(size: 11, weight: .bold))
                                .textCase(.uppercase)
                                .foregroundStyle(.white.opacity(0.9))
                        } else {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 6, height: 6)
                                .shadow(color: statusColor.opacity(0.8), radius: 4)
                            
                            Text(statusLabel)
                                .font(.system(size: 11, weight: .bold))
                                .textCase(.uppercase)
                                .foregroundStyle(statusColor)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(colorScheme == .dark ?
                                  (isOverdue ? .red.opacity(0.15) : .white.opacity(0.15))
                                  : statusColor.opacity(0.1))
                    )
                    .overlay(
                        Capsule()
                            .stroke(colorScheme == .dark ?
                                    (isOverdue ? .red.opacity(0.6) : .white.opacity(0.3))
                                    : statusColor.opacity(0.3),
                                    lineWidth: isOverdue ? 3 : 1) // Thicker border for urgent items
                    )
                    
                    Text(dateLabel)
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
            }
            .padding(16)
            .background(
                // REUSED DASHBOARD CARD LOGIC
                ZStack {
                    // 1. Dynamic Gradient Base
                    LinearGradient(
                        colors: getBaseColors(),
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    
                    // 2. Plasma Animation
                    GeometryReader { proxy in
                        ZStack {
                            if colorScheme == .dark {
                                Circle()
                                    .fill(.gray.opacity( 0.15 ))
                                    .frame(width: 150, height: 150)
                                    .blur(radius: 50)
                                    .offset(x: animate ? -30 : 30, y: animate ? -10 : 10)
                            } else {
                                Circle()
                                    .fill(statusColor.opacity(colorScheme == .dark ? 0.15 : 0.1))
                                    .frame(width: 150, height: 150)
                                    .blur(radius: 50)
                                    .offset(x: animate ? -30 : 30, y: animate ? -10 : 10)
                            }
                            
                            Circle()
                                .fill(Color.white.opacity(colorScheme == .dark ? 0.05 : 0.4))
                                .frame(width: 100, height: 100)
                                .blur(radius: 40)
                                .offset(x: animate ? 40 : -40, y: animate ? 20 : -20)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    // 3. Diamond Shimmer
                    if colorScheme == .light {
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.6), .clear],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                        .frame(width: 80)
                        .rotationEffect(.degrees(20))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 1)
                    }
                }
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            )
            .overlay(
                // 4. Chrome Bezel
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                colorScheme == .dark ? .white.opacity(0.4) : .white,
                                colorScheme == .dark ? .white.opacity(0.05) : .white.opacity(0.4),
                                colorScheme == .dark ? .white.opacity(0.2) : .white.opacity(0.8)
                            ],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: colorScheme == .dark ? Color.black.opacity(0.4) : Color.black.opacity(0.08),
                radius: 10, x: 0, y: 5
            )
            .scaleEffect(isPressed ? 0.98 : 1.0) // Tactile Press
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                //                animate.toggle()
            }
        }
    }
    
    // --- COLOR HELPERS ---
    func getBaseColors() -> [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 0.03, green: 0.03, blue: 0.04),
                Color(red: 0.06, green: 0.06, blue: 0.08)
            ]
        } else {
            return [Color(red: 0.95, green: 0.97, blue: 0.99), Color(red: 0.85, green: 0.88, blue: 0.92)]
        }
    }
}

// 4. BUTTON PRESS MODIFIER (Helper)
struct DraftGlassTouchStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0) // The Squish
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}


#Preview {
    DraftsView()
}
