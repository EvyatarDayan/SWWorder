//
//  MyListView.swift
//  SWWorder
//
//  Created by EVYATAR DAYAN on 2026-02-01.
//

import SwiftUI

struct MyListView: View {
    @StateObject private var myListManager = MyListManager.shared
    @State private var selectedWord: MyListWord? = nil
    @State private var searchText: String = ""
    @State private var showItems: Bool = false
    @State private var filterSelection: Int = 0 // 0 = All, 1 = Favorites
    @Environment(\.colorScheme) var colorScheme
    
    private var filteredWords: [MyListWord] {
        // Build base list depending on filter
        let base: [MyListWord]
        if filterSelection == 0 {
            // All: map all examples to MyListWord on the fly
            let all = WordOrderDataManager.shared.getAllExamples()
            base = all.map { example in
                MyListWord(swedish: example.answer.singleSpaced, english: example.answerTranslation.singleSpaced)
            }
        } else {
            // Favorites only
            base = myListManager.getMyListWords()
        }

        guard !searchText.isEmpty else { return base }

        return base.filter { word in
            word.swedish.lowercased().contains(searchText.lowercased()) ||
            word.english.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title - matching other views style
            ZStack {
                // Centered title
                HStack {
                    Spacer()
                    Text("My list")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 20)
            
            // Search field (only show if there are words)
            if !WordOrderDataManager.shared.getAllExamples().isEmpty {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
            
            // Filter segmented control and count
            HStack(spacing: 12) {
                Picker("", selection: $filterSelection) {
                    Text("All").tag(0)
                    Text("Favorites").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(maxWidth: 260)


                Spacer()

                // Displayed count
                Text("\(filteredWords.count) Sentences")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .padding(.top, 12)
            
            // Content
            if myListManager.getMyListWords().isEmpty {
                emptyStateView
            } else if filteredWords.isEmpty {
                // No results found
                VStack(spacing: 20) {
                    Spacer()
                    Text("No results found")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Text("Try a different search term")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 55)
            } else {
                listView
            }
        }
        .background(Color(.systemGroupedBackground))
        .clipped()
        .sheet(item: $selectedWord) { word in
            MyListWordDetailModal(word: word)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image("My list")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.secondary)
            
            Text("No words in your list")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Add words to your list from the test or practice view")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 55)
    }
    
    private var listView: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(Array(filteredWords.enumerated()), id: \.element.id) { index, word in
                    MyListWordRow(word: word, onInfoTap: {
                        selectedWord = word
                    })
                    .scaleEffect(showItems ? 1 : 0.5)
                    .opacity(showItems ? 1 : 0)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.75)
                            .delay(showItems ? Double(index) * 0.08 : Double(filteredWords.count - 1 - index) * 0.08),
                        value: showItems
                    )
                }
            }
            .padding(.vertical, 20)
            .padding(.bottom, 55) // Add padding for menu
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            showItems = true
        }
        .onChange(of: searchText) { _ in
            showItems = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showItems = true
            }
        }
    }
}

struct MyListWordRow: View {
    let word: MyListWord
    let onInfoTap: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            onInfoTap()
        }) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    // Swedish sentence (single line)
                    Text(word.swedish.singleSpaced)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    // English translation (single line)
                    Text(word.english.singleSpaced)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Info icon removed per request
            }
            .padding(16)
            .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
    }
}

struct MyListWordDetailModal: View {
    let word: MyListWord
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var myListManager = MyListManager.shared
    
    private var example: WordOrderExample? {
        let all = WordOrderDataManager.shared.getAllExamples()
        return all.first { example in
            example.answer.singleSpaced.lowercased() == word.swedish.singleSpaced.lowercased() &&
            example.answerTranslation.singleSpaced.lowercased() == word.english.singleSpaced.lowercased()
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: -10) {
                HStack {
                    Button(action: {
                        if let ex = example {
                            if myListManager.isInMyList(swedish: ex.answer, english: ex.answerTranslation) {
                                myListManager.removeFromMyList(swedish: ex.answer, english: ex.answerTranslation)
                            } else {
                                myListManager.addToMyList(swedish: ex.answer, english: ex.answerTranslation)
                            }
                        }
                    }) {
                        Image("starPlus")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor((example != nil && myListManager.isInMyList(swedish: example!.answer, english: example!.answerTranslation)) ? .green : .gray)
                            .padding(.top, 20)
                            .padding(.leading, 10)
                    }
                    Spacer()
                    Button(action: { dismiss() }) {
                        Text("Done")
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 20)
                    .padding(.trailing, 10)
                }
                .padding(.horizontal, 20)
                // Header with plain Done button (matches Details view)
                ZStack {
                    HStack {
                        Spacer()
                        Text("More info")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.bottom, 30)
                        Spacer()
                    }
                }
                .padding(.top, 50)
                .padding(.trailing, 10)


                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: 50) {
                            // Horizontal divider
                            Rectangle()
                                .fill(Color(.separator))
                                .frame(height: 5)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 0)
                                .padding(.top, 20)

                            // Swedish word with numbering above each token
                            VStack(spacing: 16) {
                                // Split sentence into tokens (normalized spacing)
                                let swedishTokens = word.swedish.singleSpaced.split(separator: " ").map { String($0) }

                                FlowLayout(spacing: 6) {
                                    ForEach(Array(swedishTokens.enumerated()), id: \.0) { idx, token in
                                        VStack(spacing: 4) {
                                            // Number above the word (black number with circular frame)
                                            Text("\(idx + 1)")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.black)
                                                .frame(width: 20, height: 20)
                                                .background(
                                                    Circle()
                                                        .fill(Color.clear)
                                                )
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.black, lineWidth: 1)
                                                )
                                                .multilineTextAlignment(.center)

                                            // The token itself
                                            Text(token)
                                                .font(.system(size: 28, weight: .bold))
                                                .foregroundColor(.blue)
                                                .multilineTextAlignment(.center)
                                        }
                                        .padding(.horizontal, 2)
                                        .padding(.vertical, 2)
                                    }
                                }
                                .frame(maxWidth: .infinity)

                                // English translation
                                Text(word.english.singleSpaced)
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)

                            // Horizontal divider
                            Rectangle()
                                .fill(Color(.separator))
                                .frame(height: 5)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 0)

                            // Tip if available
                            if let tip = example?.tip, !tip.isEmpty {
                                VStack(spacing: 8) {
                                    Text("Why?")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    Text(tip)
                                        .font(.system(size: 18, weight: .regular))
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 20)
                            }

                            // Got it button
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Got it")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.blue)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 30)

                            Spacer()
                                .frame(height: geometry.size.height * 0.1)
                        }
                        .frame(minHeight: geometry.size.height)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Helper: normalize whitespace to single spaces for display
// Improved whitespace normalization using regex (handles NBSP and other unicode spaces)
private extension String {
    var singleSpaced: String {
        let pattern = "\\s+"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let range = NSRange(self.startIndex..., in: self)
            let replaced = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: " ")
            return replaced.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    MyListView()
}
