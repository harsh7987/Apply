//
//  ShareViewController.swift
//  ApplyExtension
//
//  Created by Pranjal Verma on 10/01/26.
//

// ApplyExtension/ShareViewController.swift
import UIKit
import SwiftUI
import Social
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    let APP_GROUP_ID = "group.com.harsh007.ApplyNew"
    let APP_URL_SCHEME = "applyApp"
    
    // 1. Keep a reference to the ViewModel
    var viewModel = ShareViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 2. Set up the View ONCE
        let rootView = ShareView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: rootView)
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
        
        // 3. Start Work
        extractSharedContent()
    }
    
    func extractSharedContent() {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else { return }
        
        for item in extensionItems {
            guard let attachments = item.attachments else { continue }
            
            for provider in attachments {
                // Check URL
                if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] (data, error) in
                        if let url = data as? URL {
                            self?.saveAndRedirect(content: url.absoluteString, isURL: true)
                        }
                    }
                    return
                }
                
                // Check Text
                if provider.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
                    provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { [weak self] (data, error) in
                        if let text = data as? String {
                            self?.saveAndRedirect(content: text, isURL: false)
                        }
                    }
                    return
                }
            }
        }
    }
    
    func saveAndRedirect(content: String, isURL: Bool) {
        print("✅ Found Content: \(content)")
        // Save to App Group
        if let userDefaults = UserDefaults(suiteName: APP_GROUP_ID) {
            userDefaults.set(content, forKey: "shared_content_data")
            userDefaults.set(isURL, forKey: "shared_content_is_url")
            userDefaults.synchronize()
        } else {
            print("❌ Error: Could not load App Group. Check ID.")
        }
        
        // Update UI on Main Thread
        DispatchQueue.main.async {
            // ✅ Updates instantly without flicker
            self.viewModel.state = .success
            self.viewModel.statusMessage = "Opening App..."
            
            // Wait 1.5 seconds so user sees the checkmark, THEN open app
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.openMainApp()
            }
        }
    }
    
    func openMainApp() {
        if let url = URL(string: "\(APP_URL_SCHEME)://open") {
            var responder: UIResponder? = self
            while responder != nil {
                if let application = responder as? UIApplication {
                    application.open(url)
                    break
                }
                responder = responder?.next
            }
        }
        
        // Close the extension panel
        closeExtension()
    }
    
    // ✅ Here is your helper function!
    func closeExtension() {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
