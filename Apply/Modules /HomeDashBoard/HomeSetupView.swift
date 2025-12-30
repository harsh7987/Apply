//
//  HomeTextView.swift
//  Apply
//
//  Created by Pranjal Verma on 30/12/25.
//

import SwiftUI

struct HomeTextView: View {
    var body: some View {
        Text("Good Morning, Alex")
            .largeBoldTitle()
        Text("Ready for the next opportunity?")
            .homeSubHeadline()
    }
}

#Preview {
    HomeTextView()
}
