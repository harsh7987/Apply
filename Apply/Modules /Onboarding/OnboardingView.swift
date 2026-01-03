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
    
    @ViewBuilder
    func getView(for data: SampleData) -> some View {
        switch data.type {
        case .email:
            connectEmailButton()
        case .resume:
            getResumeButton()
        case .coverLetter:
            coverLatterButton()
        case .exTension:
            Toggle("", isOn: $obViewModel.isExtensionEnabled)
                .labelsHidden()
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
