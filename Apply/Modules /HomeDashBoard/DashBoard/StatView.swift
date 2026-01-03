//
//  StatView.swift
//  Apply
//
//  Created by Pranjal Verma on 30/12/25.
//

import SwiftUI

struct StatsViews: View {
    var stats: [StatModel] = [
        StatModel(icon: "paperplane.fill", value: 24, title: "Applications Sent"),
        StatModel(icon: "clock.fill", value: 3, title: "Follow-ups Due"),
        StatModel(icon: "phone.fill", value: 1, title: "Callbacks")
    ]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(stats) { stat in
                    StatView(statDetail: stat)
                }
            }
            .padding()
        }
    }
}

struct StatView: View {
    var statDetail: StatModel
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Image(systemName: statDetail.icon)
                .font(.title2)
                .foregroundStyle(.gray)
            Text("\(statDetail.value)")
                .largeBoldTitle2()
            Text(statDetail.title)
                .obSubHeadline().bold()
        }
        .frame(width: 130, height: 120, alignment: .topLeading).padding()
        .glossyCardBg(radius: 20)
    }
}

#Preview {
    var obj = StatModel(icon: "paperplane.fill", value: 24, title: "Applications\nSent")
    StatView(statDetail: obj)
    
//    StatsViews()
}
