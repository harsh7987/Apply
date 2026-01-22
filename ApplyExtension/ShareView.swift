//
//  ShareView.swift
//  ApplyExtension
//
//  Created by Pranjal Verma on 10/01/26.
//

// ApplyExtension/ShareView.swift
import SwiftUI

struct ShareView: View {
     var viewModel: ShareViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.state == .loading {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.blue)
                
                Text(viewModel.statusMessage)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            } else if viewModel.state == .success {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)
                
                Text("Saved!")
                    .font(.title2).bold()
                
                Text(viewModel.statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview {
    ShareView(viewModel: ShareViewModel())
}
