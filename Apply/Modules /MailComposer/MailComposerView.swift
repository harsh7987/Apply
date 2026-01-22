//
//  MailComposerView.swift
//  Apply
//
//  Created by Pranjal Verma on 11/01/26.
//

import SwiftUI
internal import MessageUI

// 1. Result Enum (Keep this)
enum ComposeResult: Equatable {
    case success(MFMailComposeResult)
    case failure(String)
}

// 2. THE NEW WRAPPER (This is what your App talks to)
// This "Container" holds the Email view AND the Interceptor logic.
struct MailComposerView: View {
    @Environment(\.dismiss) var dismiss // To close the sheet
    @State private var showDiscardAlert = false // To track the alert
    
    @Binding var result: ComposeResult?
    var subject: String
    var genratedBody: String
    var recipients: [String]
    var attachmentURL: URL?
    let coverLetterURL: URL?

    var body: some View {
        // We load the "Bridge" inside here
        MailComposerBridge(
            result: $result,
            subject: subject,
            body: genratedBody,
            recipients: recipients,
            cvURL: attachmentURL,
            coverLetterURL: coverLetterURL
        )
        // 🛑 Attach the Interceptor to this Wrapper
        .interceptDismiss(showAlert: $showDiscardAlert)
        .alert("Discard Email?", isPresented: $showDiscardAlert) {
            Button("Keep Editing", role: .cancel) { }
            Button("Discard", role: .destructive) {
                FeedbackManager.shared.trigger(.warning)
                dismiss() // This closes the sheet safely
            }
        }
        .ignoresSafeArea() // Make it look full screen
    }
}

// 3. THE BRIDGE (Your Old Code - Renamed)
// This does the heavy lifting of talking to the Apple Mail App.
struct MailComposerBridge: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    @Binding var result: ComposeResult?
    
    var subject: String
    var body: String
    var recipients: [String]
    var cvURL: URL?
    let coverLetterURL: URL?
    
    // MARK: - Controller
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        
        composer.setSubject(subject)
        composer.setMessageBody(body, isHTML: false)
        composer.setToRecipients(recipients)
        
        if let fileURL = cvURL, let fileData = try? Data(contentsOf: fileURL) {
            composer.addAttachmentData(fileData, mimeType: "application/pdf", fileName: "Resume.pdf")
        }
        
        if let cl = coverLetterURL,
           let clData = try? Data(contentsOf: cl) {
            composer.addAttachmentData(clData, mimeType: "application/pdf", fileName: "CoverLetter.pdf")
        }
        
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    // MARK: - Coordinator
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposerBridge
        
        init(parent: MailComposerBridge) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            
            if let error = error {
                parent.result = .failure(error.localizedDescription)
            } else {
                parent.result = .success(result)
            }
            
            controller.dismiss(animated: true)
        }
    }
}
