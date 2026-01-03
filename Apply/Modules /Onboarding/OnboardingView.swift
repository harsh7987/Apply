//
//  OnboardingView.swift
//  Apply
//
//  Created by Pranjal Verma on 27/12/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var uiSampleData: [SampleData] = []
    @State private var obViewModel = OnboardingViewModel()
    
    var body: some View {
        ZStack {
            BgOfView()
            VStack {
                OBSubHeadline()
                ForEach(uiSampleData) { data in
                    OnboardingCommonView(data: data) {
                        getView(for: data)
                    }
                }
                continueButton
            }
        }
        .onAppear {
            var obj = ShowData()
            obj.loadData()
            uiSampleData = obj.uiSampleData
        }
        
    }
    
    var continueButton: some View {
        VStack {
            Spacer()
            Button { } label: {
                Text("Next \(Image(systemName: "arrow.forward"))")
                    .font(.title3).bold()
                    .greenCardStyle()
            }
            .padding()
        }
    }
    
    @ViewBuilder
    func getView(for data: SampleData) -> some View {
        switch data.type {
        case .email:
            connectEmailButton()
        case .resume:
            getResumeButton()
        case .coverLetter:
            coverLatterButton()
        }
    }
    
    
    @ViewBuilder
    func getResumeButton() -> some View {
        Button { } label: {
            Text("Upload")
                .buttonDesign()
        }
    }
    
    @ViewBuilder
    func connectEmailButton() -> some View {
        Button {
            obViewModel.saveAllData()
        } label: {
            Text("Upload")
                .buttonDesign()
        }
    }
    
    @ViewBuilder
    func coverLatterButton() -> some View {
        Button { } label: {
            Text("Upload")
                .buttonDesign()
        }
    }
}

#Preview {
    OnboardingView()
}
