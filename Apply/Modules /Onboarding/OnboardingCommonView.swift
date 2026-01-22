//
//  OnboardingCommonView.swift
//  Apply
//
//  Created by Pranjal Verma on 27/12/25.
//

import SwiftUI

struct OnboardingCommonView<Content: View>: View {
    let data: OnboardingItem
    let content: Content

    
    init(data: OnboardingItem, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.data = data
    }
    
    var body: some View {
        HStack {
            imageView
            textHeadOrSub
            content
        }
        .frame(width: 360, height: 76)
        .background(.gray.opacity(0.1))
        .glossyButtons()
        .padding(4)
    }
    // Image
    var imageView: some View {
        Image(systemName: data.imageName)
            .font(.system(size: 20))
            .frame(width: 40, height: 40)
            .background(.white)
            .clipShape(Circle.circle)
    }
    // Text View
    var textHeadOrSub: some View {
        VStack(alignment: .leading) {
            Text(data.title)
                .fontWeight(.semibold)
                .lineLimit(1)
            
            Text(data.subHeading)
                .foregroundStyle(.secondary)
                .font(.system(size: 12))
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width: 160, height: 80)
        .padding(8)
    }
}

struct BackgroundView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [.yellow.opacity(0.4), .green.opacity(0.2), .blue.opacity(0.1), .yellow.opacity(0.4)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .ignoresSafeArea()
        }
    }
}

#Preview {
    OnboardingCommonView(data: OnboardingItem(imageName: "envelope.fill", title: "Connect Email", subHeading: "Email,Outlook,iCloud", type: .coverLetter)) { }
}
