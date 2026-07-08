//
//  ContentView.swift
//  SWWorder
//
//  Created by EVYATAR DAYAN on 2026-02-01.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage(WelcomeStorage.skipWelcomeKey) private var skipWelcomeScreen = false
    @State private var selectedTab: Int = 2 // Default to Practice (index 2)
    @State private var showingWelcome = true
    
    // Menu height constant - adjust this to change menu height
    private let menuHeight: CGFloat = 40
    // Menu button spacing - adjust this to change spacing between buttons (negative values bring them closer)
    private let menuButtonSpacing: CGFloat = -40
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Light gray background for entire view including safe area
                Color(.systemGroupedBackground)
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Main content area - switch based on selected tab
                    Group {
                        switch selectedTab {
                        case 0:
                            HistoryView()
                        case 1:
                            TestView()
                        case 2:
                            PracticeView()
                        case 3:
                            ListenView()
                        case 4:
                            SettingsView()
                        default:
                            PracticeView()
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height - menuHeight)
                    .clipped()
                    
                    // Footer menu with 5 buttons - simple layout with top curved background
                    ZStack(alignment: .bottom) {
                        // System background extending to bottom including safe area
                        VStack(spacing: 0) {
                            // Main menu background with curved top edges and shadow
                            UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20)
                                .fill(Color(.systemBackground))
                                .frame(width: geometry.size.width, height: menuHeight)
                                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: -3)
                            
                            // Extension to fill bottom safe area
                            Rectangle()
                                .fill(Color(.systemBackground))
                                .frame(width: geometry.size.width)
                                .frame(height: geometry.safeAreaInsets.bottom)
                        }
                        
                        // Buttons
                        HStack(spacing: menuButtonSpacing) {
                            TabBarButton(
                                icon: "history",
                                label: "History",
                                isSelected: selectedTab == 0,
                                action: { selectedTab = 0 }
                            )
                            
                            TabBarButton(
                                icon: "test",
                                label: "Test",
                                isSelected: selectedTab == 1,
                                action: { selectedTab = 1 }
                            )
                            
                            TabBarButton(
                                icon: "practice",
                                label: "Practice",
                                isSelected: selectedTab == 2,
                                action: { selectedTab = 2 }
                            )
                            
                            TabBarButton(
                                icon: "star",
                                label: "My List",
                                isSelected: selectedTab == 3,
                                action: { selectedTab = 3 }
                            )
                            
                            TabBarButton(
                                icon: "settings",
                                label: "Settings",
                                isSelected: selectedTab == 4,
                                action: { selectedTab = 4 }
                            )
                        }
                        .frame(width: geometry.size.width, height: menuHeight)
                    }
                    .zIndex(1) // Ensure menu is above content
                }
                
                // Welcome screen shown on startup (unless skipped)
                if showingWelcome && !skipWelcomeScreen {
                    LogoView {
                        withAnimation {
                            showingWelcome = false
                        }
                    }
                    .zIndex(100)
                }
            }
            .preferredColorScheme(darkModeEnabled ? .dark : nil)
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    private static let assetIcons = ["history", "star", "practice", "settings", "test"]
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // Icon - use Image for asset catalog icons
                if Self.assetIcons.contains(icon) {
                    Image(icon)
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(isSelected ? .appRed : .secondary)
                } else {
                    Text(icon)
                        .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? .appRed : .secondary)
                }
                
                // Text below icon
                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .appRed : .secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, -30)
            .padding(.bottom, 6)
        }
        .buttonStyle(PlainButtonStyle())
        .allowsHitTesting(true)
    }
}

// MARK: - Placeholder views for each tab (HistoryView is in HistoryView.swift)
// MyListView is now in MyListView.swift

struct PracticeView: View {
    var body: some View {
        WorderView()
    }
}

struct ListenView: View {
    var body: some View {
        MyListView()
    }
}

struct PlaceholderTabView: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            Text(subtitle)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
