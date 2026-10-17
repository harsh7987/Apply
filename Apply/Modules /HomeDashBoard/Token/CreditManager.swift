//
//  CreditManager.swift
//  CallBackTesting
//
//  Created by Pranjal Verma on 31/01/26.
//

import SwiftUI
import Observation
import SwiftData

// ==========================================
// 1. DATA MODEL (Unchanged)
// ==========================================
struct CreditPackage: Identifiable {
    let id = UUID()
    let title: String
    let credits: Int
    let price: String
    let tag: String?
    let color: Color
}

// ==========================================
// 2. THE UPGRADED CREDIT MANAGER
// ==========================================
@Observable
class CreditManager {
    static let shared = CreditManager()

    // 1. THE CLOUDKIT WALLET
    // This replaces your old 'totalCredits' Int.
    var activeWallet: UserWallet?

    var isTestFlight: Bool {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else { return false }
        return receiptURL.lastPathComponent == "sandboxReceipt"
    }

    let packages = [
        CreditPackage(title: "Starter Node", credits: 50, price: "$2.99", tag: nil, color: .gray),
        CreditPackage(title: "Neural Core", credits: 150, price: "$6.99", tag: "MOST POPULAR", color: .cyan),
        CreditPackage(title: "Quantum Grid", credits: 500, price: "$19.99", tag: "BEST VALUE", color: .purple)
    ]

    private init() {
        // Init is now empty! We connect to the database later.
    }

    // ==========================================
    // MARK: - CLOUDKIT CONNECTION
    // ==========================================

    // 1. JUST CONNECT (Runs instantly on app launch)
        func connectToCloud(context: ModelContext) {
            let fetchRequest = FetchDescriptor<UserWallet>()
            let existingWallets = try? context.fetch(fetchRequest)
            
            if let wallets = existingWallets, !wallets.isEmpty {
                // Sort to handle duplicates safely
                let sorted = wallets.sorted { $0.tokenBalance < $1.tokenBalance }
                self.activeWallet = sorted.first! // Safest to default to lowest if duplicates exist
                
                // Clean up duplicates
                for wallet in wallets where wallet != self.activeWallet {
                    context.delete(wallet)
                }
                print("☁️ Wallet loaded. Balance: \(activeWallet?.tokenBalance ?? 0)")
            } else {
                // DO NOTHING!
                // We do not give them tokens yet. We let CloudKit sync in the background.
                print("⏳ No wallet found yet. Waiting for cloud sync or onboarding completion.")
            }
        }

        // 2. GRANT TOKENS (Runs ONLY when they finish Onboarding)
        func grantInitialTokens(context: ModelContext) {
            let fetchRequest = FetchDescriptor<UserWallet>()
            let existingWallets = try? context.fetch(fetchRequest)
            
            if let wallets = existingWallets, !wallets.isEmpty {
                // CloudKit finished downloading their old wallet while they were doing onboarding!
                // Do NOT give them 2 tokens. Just load their real data.
                print("🚨 Caught returning user after onboarding! Loading real wallet.")
                self.activeWallet = wallets.first!
            } else {
                // They finished onboarding and STILL have no wallet. This is a true new user.
                print("🆕 True new user finished onboarding! Granted 2 tokens.")
                let newWallet = UserWallet(startingTokens: 5)
                context.insert(newWallet)
                self.activeWallet = newWallet
            }
        }

    // ==========================================
    // MARK: - CORE LOGIC FUNCTIONS
    // ==========================================

    func checkAndResetDailyTokens() {
        guard let wallet = activeWallet else { return }
        
        let today = Calendar.current.startOfDay(for: Date.now)
        let lastReset = Calendar.current.startOfDay(for: wallet.lastRefillDate)

        if lastReset < today {
            wallet.tokenBalance = 5 // Hard reset back to 2
            wallet.lastRefillDate = Date.now
            print("🔄 New calendar day! Tokens replaced and reset to 2.")
        } else {
            print("✅ Same day. Keeping current token balance: \(wallet.tokenBalance)")
        }
    }

    func deductToken() {
        if let wallet = activeWallet, wallet.tokenBalance > 0 {
            wallet.tokenBalance -= 1
            // Notice there is no UserDefaults save here!
            // SwiftData detects the change and auto-saves it to CloudKit.
        }
    }

    func purchase(package: CreditPackage) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                self.activeWallet?.tokenBalance += package.credits
            }
        }
    }
}

// ==========================================
// 2. THE CRYSTAL SUBSCRIPTION SHEET
// ==========================================

import SwiftUI

struct CrystalSubscriptionView: View {
    @Binding var isPresented: Bool
    
    // Modern Swift: No wrapper needed, just the type
    var manager: CreditManager
    
    @State private var selectedPackageID: UUID?
    @State private var isProcessing = false
    @Environment(\.colorScheme) var colorScheme
    
    var themeColor: Color { colorScheme == .dark ? .cyan : Color(red: 0.0, green: 0.2, blue: 0.7) }
    
    var body: some View {
        ZStack {
            // A. Dimmed Background
            Color.black.opacity(0.4).ignoresSafeArea()
                .onTapGesture { withAnimation { isPresented = false } }
            
            // B. The Crystal Panel
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "bolt.badge.a.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(colors: [themeColor, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .padding(.top, 20)
                    
                    Text("Recharge Neural Core")
                        .font(.title3.bold())
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    
                    Text("Select a power package to continue generation.")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                
                // Packages List
                VStack(spacing: 12) {
                    ForEach(manager.packages) { package in
                        SubscriptionCard(
                            package: package,
                            isSelected: selectedPackageID == package.id,
                            themeColor: themeColor
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedPackageID = package.id
                            }
                        }
                    }
                }
                
                // Purchase Action
                Button(action: confirmPurchase) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .tint(.black)
                        } else {
                            // 1. DYNAMIC TEXT: Change what the button says
                            Text(manager.isTestFlight ? "Purchases Disabled in Beta" : "Confirm Recharge")
                                .bold()
                            
                            if !manager.isTestFlight {
                                Image(systemName: "chevron.right")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    // 2. DYNAMIC COLOR: Keep it gray if in TestFlight
                                    colors: (selectedPackageID != nil && !manager.isTestFlight) ? [Color.orange, Color.yellow] : [.gray.opacity(0.3), .gray.opacity(0.2)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .foregroundStyle((selectedPackageID != nil && !manager.isTestFlight) ? .black : .white.opacity(0.3))
                }
                // 3. THE LOCK: Physically disable the tap if it's TestFlight
                .disabled(selectedPackageID == nil || isProcessing || manager.isTestFlight)
                
                Button("Cancel") {
                    withAnimation { isPresented = false }
                }
                .font(.footnote)
                .foregroundStyle(.gray)
                .padding(.bottom, 10)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 30)
                // MARK: - CHANGED FOR LIGHT MODE VISIBILITY
                // Dark Mode: Keeps 'ultraThin' for that deep glass look
                // Light Mode: Uses 'thick' material so it's whiter and less transparent
                    .fill(colorScheme == .dark ? Material.ultraThin : Material.thick)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(
                                LinearGradient(
                                    // Light Mode: Increased border opacity so the edge is crisper
                                    colors: colorScheme == .dark
                                    ? [.white.opacity(0.5), .white.opacity(0.0)]
                                    : [.white.opacity(0.9), .white.opacity(0.4)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: 50, x: 0, y: 10)
            )
            .padding(.horizontal, 20)
            .transition(.scale(scale: 0.9).combined(with: .opacity))
        }
    }
    
    func confirmPurchase() {
        guard let id = selectedPackageID, let package = manager.packages.first(where: { $0.id == id }) else { return }
        
        isProcessing = true
        
        // Simulate Network Call & Success
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            manager.purchase(package: package)
            isProcessing = false
            withAnimation { isPresented = false }
        }
    }
}

// ==========================================
// 3. THE SUBSCRIPTION CARD COMPONENT
// ==========================================

struct SubscriptionCard: View {
    let package: CreditPackage
    let isSelected: Bool
    let themeColor: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            // Icon Background
            ZStack {
                Circle()
                    .fill(package.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "sparkles")
                    .foregroundStyle(package.color)
            }
            
            // Text Info
            VStack(alignment: .leading, spacing: 4) {
                Text(package.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                
                Text("\(package.credits) Credits")
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            // Price & Tag
            VStack(alignment: .trailing, spacing: 4) {
                if let tag = package.tag {
                    Text(tag)
                        .font(.system(size: 8, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(package.color.opacity(0.2))
                        .foregroundStyle(package.color)
                        .cornerRadius(4)
                }
                
                Text(package.price)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? package.color.opacity(0.1) : Color.black.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? package.color : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
    }
}

// ==========================================
// 4. THE TRIGGER BUTTON
// ==========================================

struct TokenTriggerButton: View {
    // Just a regular var, Observation framework handles the rest
    var manager: CreditManager
    @Binding var showSubscription: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var themeColor: Color { colorScheme == .dark ? .cyan : Color(red: 0.0, green: 0.2, blue: 0.7) }
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            withAnimation(.spring()) {
                showSubscription.toggle()
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(themeColor)
                
                // LIVE NUMBER UPDATING
                Text("\(manager.activeWallet?.tokenBalance ?? 0)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(themeColor)
                    .contentTransition(.numericText(value: Double(manager.activeWallet?.tokenBalance ?? 0)))
                
                Text("CREDITS")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(.gray)
                
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(themeColor.opacity(0.6))
                    .padding(.leading, 2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Material.ultraThin)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        AngularGradient(
                            colors: [.clear, themeColor.opacity(0.5), .clear, themeColor.opacity(0.5), .clear],
                            center: .center
                        ),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// ==========================================
// 5. TEST PREVIEW (THE INTEGRATION)
// ==========================================

struct SubscriptionSystem_Preview: View {
    // Use @State for Observable classes in the view that owns them
    var manager = CreditManager.shared
    @State private var showSubscription = false
    
    var body: some View {
        ZStack {
            VStack {
                TokenTriggerButton(manager: manager, showSubscription: $showSubscription)
            }
            
            if showSubscription {
                CrystalSubscriptionView(isPresented: $showSubscription, manager: manager)
                    .zIndex(2)
            }
        }
    }
}

#Preview {
    SubscriptionSystem_Preview()
}
