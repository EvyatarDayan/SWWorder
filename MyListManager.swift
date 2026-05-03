//
//  MyListManager.swift
//  SWWorder
//
//  Created by EVYATAR DAYAN on 2026-02-01.
//

import Foundation
import Combine

struct MyListWord: Identifiable, Codable {
    let id: UUID
    let swedish: String
    let english: String
    let dateAdded: Date
    
    init(swedish: String, english: String) {
        self.id = UUID()
        self.swedish = swedish
        self.english = english
        self.dateAdded = Date()
    }
}

// Helper: normalize whitespace to single spaces for comparisons
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

class MyListManager: ObservableObject {
    static let shared = MyListManager()
    
    @Published private var myListWords: [MyListWord] = []
    
    private let myListKey = "myListWords"
    
    private init() {
        loadMyList()
    }
    
    func addToMyList(swedish: String, english: String) {
        // Normalize inputs and check if word already exists
        let normSwedish = swedish.singleSpaced.lowercased()
        let normEnglish = english.singleSpaced.lowercased()
        if !myListWords.contains(where: { word in
            word.swedish.singleSpaced.lowercased() == normSwedish &&
            word.english.singleSpaced.lowercased() == normEnglish
        }) {
            let newWord = MyListWord(swedish: swedish.singleSpaced, english: english.singleSpaced)
            myListWords.append(newWord)
            saveMyList()
        }
    }
    
    func removeFromMyList(swedish: String, english: String) {
        let normSwedish = swedish.singleSpaced.lowercased()
        let normEnglish = english.singleSpaced.lowercased()
        let initialCount = myListWords.count
        myListWords.removeAll { word in
            word.swedish.singleSpaced.lowercased() == normSwedish &&
            word.english.singleSpaced.lowercased() == normEnglish
        }

        if myListWords.count < initialCount {
            saveMyList()
        }
    }
    
    func isInMyList(swedish: String, english: String) -> Bool {
        let normSwedish = swedish.singleSpaced.lowercased()
        let normEnglish = english.singleSpaced.lowercased()
        return myListWords.contains { word in
            word.swedish.singleSpaced.lowercased() == normSwedish &&
            word.english.singleSpaced.lowercased() == normEnglish
        }
    }
    
    func getMyListWords() -> [MyListWord] {
        return myListWords.sorted { $0.dateAdded > $1.dateAdded } // Most recent first
    }
    
    func getMyListCount() -> Int {
        return myListWords.count
    }
    
    func clearMyList() {
        myListWords = []
        UserDefaults.standard.removeObject(forKey: myListKey)
    }
    
    private func saveMyList() {
        do {
            let encoded = try JSONEncoder().encode(myListWords)
            UserDefaults.standard.set(encoded, forKey: myListKey)
        } catch {
            print("❌ Failed to save my list: \(error)")
        }
    }
    
    private func loadMyList() {
        guard let data = UserDefaults.standard.data(forKey: myListKey) else {
            return
        }
        
        do {
            myListWords = try JSONDecoder().decode([MyListWord].self, from: data)
        } catch {
            print("❌ Failed to load my list: \(error)")
            myListWords = []
        }
    }
}
