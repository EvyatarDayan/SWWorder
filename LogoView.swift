//
//  LogoView.swift
//  SWWorder
//
//  Created by assistant on 2026-02-07.
//

import SwiftUI
import Pow
import AVFoundation
import Pow

struct LogoView: View {
    @State private var showLogo = false
    @State private var opacity = 1.0
    @State private var backgroundOpacity = 1.0
    @State private var audioPlayer: AVAudioPlayer?
    let onAnimationComplete: () -> Void

    private var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }

    private func playLogoSound() {
        if let path = Bundle.main.path(forResource: "logo3", ofType: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.play()
            } catch {
                print("Could not play sound file: \(error)")
            }
        }
    }

    var body: some View {
        ZStack {
            // Background - now with its own opacity
            Color.white
                .ignoresSafeArea()
                .opacity(backgroundOpacity)

            // Logo image / text
            if showLogo {
                Image("AbaShelAriLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: isIPhone ? 350 : 700)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.1))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .foregroundColor(.white)
                    .opacity(opacity)
                    .transition(
                        .identity
                            .animation(.linear(duration: 2.5).delay(2.5))
                            .combined(with: .movingParts.glare)
                    )
            }
        }
        .onAppear {
            // Delay the start of the logo animation
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                withAnimation {
                    showLogo = true
                    // Play logo sound when the logo appears
                    playLogoSound()
                }
            }

            // Duration of logo display
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                // First fade out the logo
                withAnimation(.easeOut(duration: 1)) {
                    opacity = 0
                }

                // Start fading out the background and trigger main view
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    // Trigger main view to appear
                    onAnimationComplete()

                    // Fade out background slowly
                    withAnimation(.easeOut(duration: 1)) {
                        backgroundOpacity = 0
                    }
                }
            }
        }
    }
}

#if DEBUG
struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView {
            print("Animation complete")
        }
    }
}
#endif

