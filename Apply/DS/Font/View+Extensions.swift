//
//  View+Extensions.swift
//  Apply
//
//  Created by Pranjal Verma on 29/12/25.
//

import SwiftUI

extension View {
    
    func largeBoldTitle() -> some View {
        self.font(.system(size: 25, weight: .bold))
    }
    
    func largeBoldTitle2() -> some View {
        self.font(.largeTitle).bold()
    }
    
    func obSubHeadline() -> some View {
        self.font(.system(size: 18))
            .foregroundStyle(.secondary)
    }
    
    func homeSubHeadline() -> some View {
        self.font(.system(size: 22))
            .foregroundStyle(.black.opacity(0.5))
    }
    
    func glassyStyle() -> some View {
            self.padding()
            .frame(width: 66, height: 66)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.8), lineWidth: 1) 
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
    
    func glossyButtons() -> some View {
        self.background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 40))
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(.white.opacity(0.8), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    func greenCardStyle() -> some View {
        self.foregroundStyle(.black)
            .frame(width: 360, height: 62)
            .background(.yellow.opacity(1))
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 40))
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(.white.opacity(0.8), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    func whiteCardStyle() -> some View {
        self.font(.headline)
            .fontWeight(.bold)
            .foregroundStyle(.black.opacity(0.8))
                .frame(width: 168, height: 52)
    }
    
    func glossyCardBg(radius: CGFloat) -> some View {
        self.background(.white.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(.white.opacity(0.8), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
            .padding(8)
    }
}
