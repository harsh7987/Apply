//
//  ShareViewModel.swift
//  ApplyExtension
//
//  Created by Pranjal Verma on 10/01/26.
//

// ApplyExtension/ShareViewModel.swift
import SwiftUI

@Observable
class ShareViewModel {
    enum ShareState {
        case loading
        case success
        case error
    }
    
     var state: ShareState = .loading
     var statusMessage: String = "Saving..."
}
