//
//  HomeTextView.swift
//  Apply
//
//  Created by Pranjal Verma on 30/12/25.
//

import SwiftUI

struct ProfileAndSet: View {
    var body: some View {
        HStack {
            Button { } label: {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 55))
                    .frame(width: 55, height: 55)
                    .foregroundStyle(.black.opacity(0.8))
                    .glossyCardBg(radius: 30)
            }
            Spacer()
            Button { } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 25))
                    .frame(width: 55, height: 55)
                    .foregroundStyle(.black.opacity(0.8))
                    .glossyCardBg(radius: 40)
            }
        }
//        .padding()
    }
}

struct HomeTextView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Good Morning, Alex.")
                .largeBoldTitle2()
            Text("Ready for the next opportunity?")
                .homeSubHeadline()
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding()
    }
}

struct RoundedButtonView: View {
    var body: some View {
        Button {} label: {
            Text("\(Image(systemName: "link"))  Create from share post")
                .font(.title3)
                .fontWeight(.heavy)
                .greenCardStyle()
        }
        
        HStack {
            Button { } label: {
                Text("\(Image(systemName: "link.circle"))  Paste Link")
                    .whiteCardStyle()
                    .glossyCardBg(radius: 40)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
            Button { } label: {
                Text("\(Image(systemName:"clipboard"))  Import")
                    .whiteCardStyle()
                    .glossyCardBg(radius: 40)
            }
        }
    }
}
#Preview {
    RoundedButtonView()
//    ProfileAndSet()
//    HomeTextView()
}
