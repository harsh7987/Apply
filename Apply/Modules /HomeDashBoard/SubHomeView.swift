//
//  SubHomeView.swift
//  Apply
//
//  Created by Pranjal Verma on 30/12/25.
//

import SwiftUI

struct SubHomeView: View {
    var body: some View {
        ZStack {
            BgOfView()
            VStack(alignment: .center) {
                ProfileAndSet()
                    .padding()
                HomeTextView()
                
                StatsViews()
                
               RoundedButtonView()
                Spacer()
                
                    
            }
            .ignoresSafeArea()
            
        }
    }
}

struct gridView2: View {
    var body: some View {
        Text("grid3")
    }
}

struct gridView3: View {
    var body: some View {
        Text("grid4")
    }
}

struct gridView4: View {
    var body: some View {
        Text("grid4")
    }
}

struct TabBar: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("", systemImage: "house.fill")
                }
            
            gridView2()
                .tabItem {
                    Label("", systemImage: "folder.badge.plus.fill")
                }
            
            gridView3()
                .tabItem {
                    Label("", systemImage: "plus.circle")
                    
                }
            
            gridView4()
                .tabItem {
                    Label("", systemImage: "document.on.document.fill")
                }
            }
        }
}

#Preview {
    TabBar()
}
