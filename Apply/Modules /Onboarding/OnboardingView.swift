//
//  OnboardingView.swift
//  Apply
//
//  Created by Pranjal Verma on 27/12/25.
//

import SwiftUI
import SwiftData
internal import UniformTypeIdentifiers

struct OnboardingView: View {
    @State private var viewmodel = OnboardingViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query var user: [UserProfile]
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                OBSubHeadline()
                ForEach(viewmodel.onBoardingItems) { data in
                    OnboardingCommonView(data: data) {
                        getItemView(for: data)
                    }
                }
                
                if let error = viewmodel.errorMessage {
                    Text(error).foregroundStyle(.red).font(.caption)
                }
                nextButton
            }
        }
        .onAppear {
            viewmodel.checkUploadStatus()
        }
        .fileImporter(isPresented: $viewmodel.importResume,
                      allowedContentTypes: [.pdf],
                      allowsMultipleSelection: false) { result in
            switch result {
            case .success(let url):
                if let url = url.first {
                    
                    Task {
                        await viewmodel.processSelectResume(resumeURL: url, modelContext: modelContext)
                    }
                }
            case .failure(let failure):
                viewmodel.errorMessage = failure.localizedDescription
            }
            
        }
                      .sheet(isPresented: $viewmodel.showReviewSheet) {
                          if let user = user.first {
                              NavigationStack {
                                  ProfileEditView(user: user, isOnboarding: true) {
                                      viewmodel.isPresentHomeView = true
                                  }
                              }
                          }
                      }
                      .fullScreenCover(isPresented: $viewmodel.isPresentHomeView) {
                          // handle dismiss
                      } content: {
                          HomeView()
                      }
        //  COVER LETTER
                      .fileImporter(isPresented: $viewmodel.importCover,
                                    allowedContentTypes: [.pdf],
                                    allowsMultipleSelection: false) { result in
                          switch result {
                          case .success(let urls):
                              if let url = urls.first {
                                  // ✅ Wrap in do-catch to handle errors safely
                                  do {
                                      try CoverLetterManager.shared.saveCoverLetter(from: url)
                                      
                                      // Update UI immediately
                                      viewmodel.isCoverUploaded = true
                                      FeedbackManager.shared.trigger(.success)
                                      print("✅ Cover letter saved successfully.")
                                  } catch {
                                      print("❌ Failed to save file: \(error.localizedDescription)")
                                      FeedbackManager.shared.trigger(.error)
                                  }
                              }
                          case .failure(let error):
                              print("❌ Import failed: \(error.localizedDescription)")
                          }
                      }
        
    }
    
    var nextButton: some View {
        VStack {
            Spacer()
            Button {
                viewmodel.isPresentHomeView.toggle()
            } label: {
                Text("Next \(Image(systemName: "arrow.forward"))")
                    .font(.title3).bold()
                    .greenCardStyle()
            }
            .padding()
        }
    }
    
    @ViewBuilder
    func getItemView(for data: OnboardingItem) -> some View {
        switch data.type {
        case .resume:
            resumeButton
        case .coverLetter:
            coverLetterButton
        }
    }
    
    var resumeButton: some View {
        Button {
            viewmodel.importResume.toggle()
        } label: {
            HStack {
                // Change Text based on State
                if viewmodel.isExtracting {
                    ProgressView()
                } else if viewmodel.uploadSucces {
                    Image(systemName: "checkmark.circle.fill")
                } else {
                    Text("Upload")
                }
            }
            .buttonDesign()
        }
        .disabled(viewmodel.isExtracting || viewmodel.uploadSucces)
    }
    
    var coverLetterButton: some View {
        Button { } label: {
            HStack {
                if viewmodel.uploadSucces {
                    Image(systemName: "checkmark.circle.fill")
                } else {
                    Text("Upload")
                }
            }
            .buttonDesign()
        }
    }
    
    //    @ViewBuilder
    //    func connectEmailButton() -> some View {
    //        Button {
    //            viewmodel.saveAllData()
    //        } label: {
    //            Text("Upload")
    //                .buttonDesign()
    //        }
    //    }
}

#Preview {
    OnboardingView()
}
