//
//  TextViews.swift
//  Apply
//
//  Created by Pranjal Verma on 28/12/25.
//

import SwiftUI

struct OBMainHeadline: View {
    var body: some View {
        Text("Let's set up your \nworkspace.")
            .largeBoldTitle()
    }
}

struct OBSubHeadline: View {
    var body: some View {
        VStack() {

                Image(systemName: "sparkles")
                    .font(.system(size: 30))
                    .glassyStyle()
                
                OBMainHeadline()
                    .padding(.vertical)
                
                Text("Connect your tools to auto-generate\nperfect applications.")
                    .obSubHeadline()
        
        }
    }
}

struct OBButtons: View {
    var body: some View {
        VStack {
            Spacer()
            Button {
                
                
                
            } label: {
                Text("Continue \(Image(systemName: "arrow.forward"))")
                    .font(.title2).bold()
                    .greenCardStyle()
            }
            .padding()
            Button { } label: {
                Text("Skip setup for now")
            }
        }
    }
}

#Preview {
    OBSubHeadline()
}


