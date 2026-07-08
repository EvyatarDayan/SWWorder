//
//  LogoView.swift
//  SWWorder
//
//  Created by EVYATAR DAYAN on 2026-01-28.
//

import SwiftUI

enum WelcomeStorage {
    static let skipWelcomeKey = "skipWelcomeScreen"
}

struct SplitTitleView: View {
    let text: String
    let splitIndex: Int
    let fontSize: CGFloat

    init(_ text: String, splitIndex: Int, fontSize: CGFloat) {
        self.text = text
        self.splitIndex = splitIndex
        self.fontSize = fontSize
    }

    var body: some View {
        let safeIndex = min(max(splitIndex, 0), text.count)
        let split = text.index(text.startIndex, offsetBy: safeIndex)
        let firstPart = String(text[..<split])
        let secondPart = String(text[split...])
        (Text(firstPart).foregroundColor(.appRed) + Text(secondPart).foregroundColor(.appRed))
            .font(.system(size: fontSize, weight: .bold))
            .multilineTextAlignment(.center)
    }
}

struct LogoView: View {
    var onStart: () -> Void
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage(WelcomeStorage.skipWelcomeKey) private var skipWelcomeScreen = false
    @State private var dontShowAgain = false

    var body: some View {
        ZStack {
            (darkModeEnabled ? Color.black : Color(.systemGroupedBackground))
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 20) {
                    logoView

                    SplitTitleView("Welcome to SW-Worder", splitIndex: 11, fontSize: 28)

                    Text("Practice Swedish word order with sentence blocks - V2 rule, negation, questions, and auxiliaries. Track your progress, run tests, and build confident Swedish sentence structure.")
                        .font(.body)
                        .foregroundColor(darkModeEnabled ? .white : .black)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 4)
                        .padding(.top, 15)

                    Button(action: startApp) {
                        Text("Get Started")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.appRed)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 40)
                }
                .padding(.horizontal, 32)

                Spacer()

                Button {
                    dontShowAgain.toggle()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: dontShowAgain ? "checkmark.square.fill" : "square")
                            .font(.title3)
                            .foregroundStyle(dontShowAgain ? Color.appRed : Color.gray)

                        Text("Don't show this again")
                            .font(.subheadline)
                            .foregroundStyle(.gray)

                        Spacer(minLength: 0)
                    }
                    .padding(.bottom, 20)
                    .padding(.leading, 20)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .preferredColorScheme(darkModeEnabled ? .dark : .light)
    }

    private func startApp() {
        if dontShowAgain {
            skipWelcomeScreen = true
        }
        onStart()
    }

    private var logoView: some View {
        Image("SwedishLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 160, height: 160)
    }
}

#Preview {
    LogoView(onStart: {})
}
