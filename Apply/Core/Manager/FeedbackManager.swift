//
//  FeedbackManager.swift
//  Apply
//
//  Created by Pranjal Verma on 22/01/26.
//

import UIKit
import AudioToolbox
import AVFoundation

class FeedbackManager {
    static let shared = FeedbackManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() {} // Singleton
    
    // 1. Haptic Feedback (Vibrations)
    func trigger(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    // 2. Sound Effects (System Sounds)
    func playSendSound() {
        // ID 1001 is the standard "Mail Sent" swoosh sound
        AudioServicesPlaySystemSound(1001)
    }
    
    func playErrorSound() {
        // ID 1053 is a standard alert/error sound
        AudioServicesPlaySystemSound(1053)
    }
    
    func playTokenSpendSound() {
            // Haptic: Use .rigid or .heavy to feel like a solid coin hitting a jar
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()

            // Sound: Play your custom file
            guard let url = Bundle.main.url(forResource: "coins", withExtension: "mp3") else {
                print("⚠️ Could not find coins.mp3")
                return
            }

            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.volume = 0.2
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("❌ Error playing sound: \(error)")
            }
        }
}
