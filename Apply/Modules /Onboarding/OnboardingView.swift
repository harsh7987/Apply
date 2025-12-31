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
        Button {
            
            
        } label: {
            Text("Continue \(Image(systemName: "arrow.forward"))")
                .font(.title2).bold()
                .greenCardStyle()
        }
    }
    
    @ViewBuilder
    func getView(for data: SampleData) -> some View {
        switch data.type {
        case .email:
            Rectangle()
                .frame(width: 100, height: 100)
                .foregroundColor(.red)
        case .resume:
            getResumeButton()
        case .coverLetter:
            Rectangle()
                .frame(width: 100, height: 100)
                .foregroundColor(.red)
        case .exTension:
            Toggle("isOne", isOn: $obViewModel.isExtensionEnabled)
        }
    }
    
    
    @ViewBuilder
    func getResumeButton() -> some View {
        Button("TEst") {
            print("Opne Resume")
        }
    }
    

}

#Preview {
    OnboardingView()
}
