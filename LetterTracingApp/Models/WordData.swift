import Foundation

struct WordItem {
    let word: String
    let emoji: String
    let firstLetter: String

    init(word: String, emoji: String) {
        self.word = word.lowercased()
        self.emoji = emoji
        self.firstLetter = String(word.prefix(1)).lowercased()
    }
}

struct LetterSet {
    let letter: String
    let words: [WordItem]
}

class WordDataManager {
    static let shared = WordDataManager()

    private init() {}

    // CVC words organized by starting letter
    let letterSets: [LetterSet] = [
        LetterSet(letter: "b", words: [
            WordItem(word: "bat", emoji: "🦇"),
            WordItem(word: "bed", emoji: "🛏️"),
            WordItem(word: "bug", emoji: "🐛"),
            WordItem(word: "box", emoji: "📦"),
            WordItem(word: "bus", emoji: "🚌"),
            WordItem(word: "bun", emoji: "🍔"),
            WordItem(word: "bin", emoji: "🗑️"),
            WordItem(word: "bag", emoji: "👜")
        ]),
        LetterSet(letter: "c", words: [
            WordItem(word: "cat", emoji: "🐱"),
            WordItem(word: "car", emoji: "🚗"),
            WordItem(word: "cup", emoji: "☕"),
            WordItem(word: "cow", emoji: "🐮"),
            WordItem(word: "can", emoji: "🥫"),
            WordItem(word: "cap", emoji: "🧢"),
            WordItem(word: "cub", emoji: "🐻"),
            WordItem(word: "cot", emoji: "🛏️")
        ]),
        LetterSet(letter: "d", words: [
            WordItem(word: "dog", emoji: "🐕"),
            WordItem(word: "dot", emoji: "⚫"),
            WordItem(word: "dad", emoji: "👨"),
            WordItem(word: "den", emoji: "🏠"),
            WordItem(word: "dip", emoji: "🫕"),
            WordItem(word: "dam", emoji: "🦫"),
            WordItem(word: "dig", emoji: "⛏️"),
            WordItem(word: "din", emoji: "🔊")
        ]),
        LetterSet(letter: "f", words: [
            WordItem(word: "fox", emoji: "🦊"),
            WordItem(word: "fan", emoji: "🪭"),
            WordItem(word: "fig", emoji: "🫒"),
            WordItem(word: "fin", emoji: "🐟"),
            WordItem(word: "fun", emoji: "🎉"),
            WordItem(word: "fed", emoji: "🍽️"),
            WordItem(word: "fog", emoji: "🌫️"),
            WordItem(word: "fad", emoji: "✨")
        ]),
        LetterSet(letter: "h", words: [
            WordItem(word: "hat", emoji: "🎩"),
            WordItem(word: "hop", emoji: "🦘"),
            WordItem(word: "hen", emoji: "🐔"),
            WordItem(word: "ham", emoji: "🍖"),
            WordItem(word: "hug", emoji: "🤗"),
            WordItem(word: "hot", emoji: "🔥"),
            WordItem(word: "hut", emoji: "🛖"),
            WordItem(word: "hip", emoji: "🦴")
        ]),
        LetterSet(letter: "p", words: [
            WordItem(word: "pig", emoji: "🐷"),
            WordItem(word: "pen", emoji: "🖊️"),
            WordItem(word: "pet", emoji: "🐾"),
            WordItem(word: "pot", emoji: "🍲"),
            WordItem(word: "pin", emoji: "📌"),
            WordItem(word: "pat", emoji: "🤚"),
            WordItem(word: "pup", emoji: "🐶"),
            WordItem(word: "pan", emoji: "🍳")
        ]),
        LetterSet(letter: "r", words: [
            WordItem(word: "rat", emoji: "🐀"),
            WordItem(word: "run", emoji: "🏃"),
            WordItem(word: "red", emoji: "🔴"),
            WordItem(word: "rug", emoji: "🧶"),
            WordItem(word: "rod", emoji: "🎣"),
            WordItem(word: "ram", emoji: "🐏"),
            WordItem(word: "rip", emoji: "✂️"),
            WordItem(word: "rap", emoji: "🎤")
        ]),
        LetterSet(letter: "s", words: [
            WordItem(word: "sun", emoji: "☀️"),
            WordItem(word: "sit", emoji: "🪑"),
            WordItem(word: "sip", emoji: "🥤"),
            WordItem(word: "sad", emoji: "😢"),
            WordItem(word: "set", emoji: "📺"),
            WordItem(word: "sub", emoji: "🥖"),
            WordItem(word: "sap", emoji: "🌲"),
            WordItem(word: "sob", emoji: "😭")
        ]),
        LetterSet(letter: "t", words: [
            WordItem(word: "top", emoji: "🔝"),
            WordItem(word: "ten", emoji: "🔟"),
            WordItem(word: "tap", emoji: "🚰"),
            WordItem(word: "tan", emoji: "🟤"),
            WordItem(word: "tip", emoji: "💡"),
            WordItem(word: "tub", emoji: "🛁"),
            WordItem(word: "tag", emoji: "🏷️"),
            WordItem(word: "tin", emoji: "🥫")
        ])
    ]

    func getLetterSet(for letter: String) -> LetterSet? {
        return letterSets.first { $0.letter == letter.lowercased() }
    }

    // Split 8 words into two pages of 4 words each
    func getPages(for letterSet: LetterSet) -> [[WordItem]] {
        let words = letterSet.words
        let page1 = Array(words.prefix(4))
        let page2 = Array(words.dropFirst(4).prefix(4))
        return [page1, page2]
    }
}
